// ============================================================================
// runtime/web/platform.js — the web's window, keyboard and filesystem.
//
// This file is the browser's answer to runtime/native/cocoa.ll, and it has the
// same job and the same size: implement the five-function platform protocol
//
//     win_open(w, h, scale, title)   win_poll() -> key   win_present(fb, w, h)
//     win_running() -> bool          win_close()
//
// plus the handful of host services wasm has no OS to ask for — files, the
// clock, stdout. Nothing else. The game, the ECS, the framebuffer, the PNG
// decoder, the TrueType rasteriser and the UI are all compiled Ludic running
// inside the wasm module; no game logic passes through this file, and none of
// it is interpreted.
//
//     const game = await LudicWeb.start({ wasm: 'chronorift.wasm',
//                                         canvas: document.querySelector('canvas'),
//                                         manifest: 'assets.json' })
// ============================================================================

export const LudicWeb = { start };

// ---------------------------------------------------------------------------
// Keyboard. win_poll() reports the last key pressed since the previous frame,
// as a character code, or 0 for none — exactly what cocoa.ll reports. Arrow
// keys fold onto WASD and Escape onto 'q', so a game written for the native
// build needs no web-specific input handling.
// ---------------------------------------------------------------------------
const KEY_ALIASES = {
  ArrowUp: 'w', ArrowLeft: 'a', ArrowDown: 's', ArrowRight: 'd',
  Escape: 'q', Enter: '\r', Backspace: '\b', Tab: '\t',
};

function keyCode(ev) {
  const alias = KEY_ALIASES[ev.key];
  if (alias) return alias.charCodeAt(0);
  if (ev.key.length === 1) return ev.key.charCodeAt(0);
  return 0;
}

// ---------------------------------------------------------------------------
// A read-only image of the game's files, plus a writable overlay in
// localStorage for save games.
//
// The Ludic runtime opens assets with file_open()/file_read(), which on a
// native build is fopen/fread. The browser has no synchronous file access, so
// every file the game can open is fetched up front (see the manifest ludicc
// emits beside the .wasm) and served out of memory. Saves go the other way:
// file_open("game.sav","wb") buffers, and fclose commits to localStorage, so
// save/load survives a page reload.
// ---------------------------------------------------------------------------
export class Files {
  constructor(preloaded, storageKey) {
    this.assets = preloaded;              // Map<string, Uint8Array>
    this.storageKey = storageKey;
    this.open = new Map();                // handle -> {data, pos, path, write}
    this.next = 1;                        // 0 is NULL to the Ludic side
  }

  saved(path) {
    try {
      const raw = localStorage.getItem(this.storageKey + path);
      if (raw === null) return null;
      const bytes = new Uint8Array(raw.length);
      for (let i = 0; i < raw.length; i++) bytes[i] = raw.charCodeAt(i) & 0xff;
      return bytes;
    } catch { return null; }
  }

  commit(path, data) {
    try {
      let raw = '';
      for (let i = 0; i < data.length; i += 0x8000)
        raw += String.fromCharCode.apply(null, data.subarray(i, i + 0x8000));
      localStorage.setItem(this.storageKey + path, raw);
    } catch (e) {
      console.warn('ludic: could not persist', path, e);
    }
  }

  fopen(path, mode) {
    const writing = mode.includes('w') || mode.includes('a');
    if (writing) {
      const h = this.next++;
      this.open.set(h, { path, pos: 0, write: true, chunks: [], size: 0 });
      return h;
    }
    // Reads prefer a save the player has made over the shipped asset.
    const data = this.saved(path) || this.assets.get(path) ||
                 this.assets.get(path.replace(/^\.\//, ''));
    if (!data) return 0;                          // NULL: the game handles it
    const h = this.next++;
    this.open.set(h, { path, pos: 0, write: false, data });
    return h;
  }

  fread(h, dst, want) {
    const f = this.open.get(h);
    if (!f || f.write) return 0;
    const n = Math.max(0, Math.min(want, f.data.length - f.pos));
    dst.set(f.data.subarray(f.pos, f.pos + n));
    f.pos += n;
    return n;
  }

  fwrite(h, src, n) {
    const f = this.open.get(h);
    if (!f || !f.write) return 0;
    f.chunks.push(src.slice(0, n));               // copy: wasm memory is reused
    f.size += n;
    f.pos += n;
    return n;
  }

  fclose(h) {
    const f = this.open.get(h);
    if (!f) return;
    if (f.write) {
      const all = new Uint8Array(f.size);
      let at = 0;
      for (const c of f.chunks) { all.set(c, at); at += c.length; }
      this.commit(f.path, all);
    }
    this.open.delete(h);
  }

  fseek(h, off, whence) {
    const f = this.open.get(h);
    if (!f) return -1;
    const end = f.write ? f.size : f.data.length;
    const base = whence === 1 ? f.pos : whence === 2 ? end : 0;
    f.pos = Math.max(0, Math.min(end, base + off));
    return 0;
  }

  ftell(h) {
    const f = this.open.get(h);
    return f ? f.pos : -1;
  }
}

// ---------------------------------------------------------------------------
// The canvas. win_present() hands over a pointer to the framebuffer — one
// 0x00RRGGBB word per pixel — which is transcoded into the RGBA byte order
// ImageData wants and blitted at the requested integer scale.
// ---------------------------------------------------------------------------
class Screen {
  constructor(canvas) {
    this.canvas = canvas;
    this.ctx = null;
    this.image = null;
    this.w = 0; this.h = 0;
  }

  open(w, h, scale, title) {
    this.w = w; this.h = h;
    this.canvas.width = w;
    this.canvas.height = h;
    // The backing store stays at the framebuffer's own resolution and CSS does
    // the scaling, so a 320x240 game stays crisp on a HiDPI display.
    //
    // How big to draw it is the page's decision, not the platform layer's: a 3x
    // 320x240 window is 720px tall and does not fit a laptop viewport once there
    // is a title above it. So this publishes the framebuffer's dimensions and
    // the scale the game asked for, and leaves the fitting to CSS — see the
    // width rule in runtime/web/index.html.
    const css = this.canvas.style;
    css.setProperty('--ludic-w', String(w));
    css.setProperty('--ludic-h', String(h));
    css.setProperty('--ludic-scale', String(scale));
    css.aspectRatio = w + ' / ' + h;
    css.height = 'auto';
    css.imageRendering = 'pixelated';
    this.ctx = this.canvas.getContext('2d', { alpha: false });
    this.ctx.imageSmoothingEnabled = false;
    this.image = this.ctx.createImageData(w, h);
    this.rgba = new Uint32Array(this.image.data.buffer);
    if (title) document.title = title;
  }

  present(words, w, h) {
    if (!this.ctx) return;
    if (w !== this.w || h !== this.h) this.open(w, h, 1, null);
    const dst = this.rgba;
    // Little-endian ImageData is 0xAABBGGRR; the framebuffer is 0x00RRGGBB.
    for (let i = 0, n = w * h; i < n; i++) {
      const c = words[i];
      dst[i] = 0xff000000 | ((c & 0xff) << 16) | (c & 0xff00) | ((c >>> 16) & 0xff);
    }
    this.ctx.putImageData(this.image, 0, 0);
  }
}

// ---------------------------------------------------------------------------
// Host — the memory views and the services wasm has no OS to ask for.
//
// A wasm module's linear memory is detached and replaced every time it grows,
// so every view has to be re-derived rather than cached across a call. Beyond
// that this is just the non-window half of the platform: files, stdin, stdout
// and the clock. The browser and Node need exactly the same set, so the Node
// test runner (tools/ludic-web/run.mjs) builds on this class too, and only the
// five win_* functions differ between the two hosts.
// ---------------------------------------------------------------------------
export class Host {
  constructor({ files, stdin = '', log = console.log } = {}) {
    this.files = files;
    this.stdin = stdin;
    this.stdinAt = 0;
    this.log = log;
    this.line = '';
    this.memory = null;
    this.buffer = null;
    this.running = 1;
    this.exitCode = null;
  }

  bind(memory) { this.memory = memory; this.sync(); }

  sync() {
    if (this.memory.buffer !== this.buffer) {
      this.buffer = this.memory.buffer;
      this.u8 = new Uint8Array(this.buffer);
      this.u32 = new Uint32Array(this.buffer);
    }
  }

  cstr(p) {
    this.sync();
    let end = p;
    while (this.u8[end] !== 0) end++;
    return new TextDecoder().decode(this.u8.subarray(p, end));
  }

  flush() { if (this.line) { this.log(this.line); this.line = ''; } }

  imports() {
    const fs = this.files;
    return {
      web_fopen: (path, mode) => fs.fopen(this.cstr(path), this.cstr(mode)),
      web_fread: (h, dst, n) => { this.sync(); return fs.fread(h, this.u8.subarray(dst, dst + n), n); },
      web_fwrite: (h, src, n) => { this.sync(); return fs.fwrite(h, this.u8.subarray(src, src + n), n); },
      web_fclose: (h) => fs.fclose(h),
      web_fseek: (h, off, whence) => fs.fseek(h, off, whence),
      web_ftell: (h) => fs.ftell(h),

      web_getchar: () => (this.stdinAt < this.stdin.length ? this.stdin.charCodeAt(this.stdinAt++) : -1),
      web_putchar: (c) => { if (c === 10) this.flush(); else this.line += String.fromCharCode(c); },
      web_print_str: (p) => { this.line += this.cstr(p); },
      // print_int(n) is printf("%d\n", n) natively, newline included.
      web_print_int: (n) => { this.line += String(n); this.flush(); },
      web_time: () => Math.floor(Date.now() / 1000),
      web_exit: (code) => {
        this.running = 0; this.exitCode = code; this.flush();
        throw new ExitSignal(code);
      },
    };
  }
}

// ---------------------------------------------------------------------------
// start() — fetch the module and its assets, wire the imports, run the loop.
//
// The native entry point is `while (alive) frame();`. A browser tab cannot be
// held that way, so a web build exports the loop's parts instead —
// ludic_boot / ludic_frame / ludic_alive / ludic_teardown — and this drives
// them from requestAnimationFrame. The systems that run per frame, and their
// order, are identical; only who owns the loop changes.
// ---------------------------------------------------------------------------
async function start({ wasm, canvas, manifest = null, files = {}, onExit = null,
                       stdin = '', storageKey = 'ludic:' } = {}) {
  const assets = new Map();
  for (const [path, bytes] of Object.entries(files)) assets.set(path, bytes);

  if (manifest) {
    const list = await (await fetch(manifest)).json();
    await Promise.all(list.map(async (path) => {
      const res = await fetch(path);
      if (!res.ok) { console.warn('ludic: missing asset', path); return; }
      assets.set(path, new Uint8Array(await res.arrayBuffer()));
    }));
  }

  const host = new Host({ files: new Files(assets, storageKey) });
  const screen = new Screen(canvas);
  let pendingKey = 0;

  const env = {
    ...host.imports(),
    // The window, which is the only part of the platform the browser and the
    // test runner do not share.
    win_open: (w, h, scale, title) => screen.open(w, h, scale || 1, host.cstr(title)),
    win_poll: () => { const k = pendingKey; pendingKey = 0; return k; },
    win_present: (fb, w, h) => {
      host.sync();
      screen.present(host.u32.subarray(fb >>> 2, (fb >>> 2) + w * h), w, h);
    },
    win_running: () => host.running,
    win_close: () => { host.running = 0; },
  };

  const { instance } = await WebAssembly.instantiateStreaming(fetch(wasm), { env });
  host.bind(instance.exports.memory);

  const { ludic_boot, ludic_frame, ludic_alive, ludic_teardown } = instance.exports;

  const onKey = (ev) => {
    const k = keyCode(ev);
    if (k) { pendingKey = k; ev.preventDefault(); }
  };
  window.addEventListener('keydown', onKey);

  const game = {
    instance,
    exports: instance.exports,
    // Lets a page wire on-screen buttons for touch devices: game.press('w').
    press: (k) => { pendingKey = typeof k === 'string' ? k.charCodeAt(0) : k; },
    stop: () => { host.running = 0; },
  };

  let stopped = false;
  const finish = () => {
    if (stopped) return;
    stopped = true;
    window.removeEventListener('keydown', onKey);
    try { ludic_teardown(); } catch (e) { if (!(e instanceof ExitSignal)) throw e; }
    host.flush();
    if (onExit) onExit(host.exitCode ?? 0);
  };

  const step = () => {
    if (stopped) return;
    try {
      if (!host.running || !ludic_alive()) return finish();
      ludic_frame();
    } catch (e) {
      if (e instanceof ExitSignal) return finish();
      stopped = true;
      window.removeEventListener('keydown', onKey);
      throw e;
    }
    requestAnimationFrame(step);
  };

  try { ludic_boot(); } catch (e) {
    if (!(e instanceof ExitSignal)) throw e;
    finish();
    return game;
  }
  requestAnimationFrame(step);
  return game;
}

// os_exit() has to unwind the wasm frame it was called from; there is no
// process to terminate, so it throws and the loop treats it as the end.
export class ExitSignal extends Error {
  constructor(code) { super('ludic: exit(' + code + ')'); this.code = code; }
}
