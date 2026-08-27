// ============================================================================
// tools/ludic-web/run.mjs — run a headless Ludic wasm build under Node.
//
//     node tools/ludic-web/run.mjs build/web/snake_headless.wasm --stdin=ddss
//
// The point of this runner is the regression it makes possible: the same game,
// the same input, compiled once for the host and once for wasm32, has to render
// the same frame. Ludic is fixed-point and its RNG is seeded, so "the same" here
// means byte-identical PPM — which is a much stronger check on the wasm backend
// than "it started".
//
// It shares runtime/web/platform.js's Host: files, stdin, stdout and the clock
// are identical services whichever host provides them. Only the window differs,
// and a headless build has none.
// ============================================================================
import { readFileSync, writeFileSync, existsSync } from 'node:fs';
import { Host, ExitSignal } from '../../runtime/web/platform.js';

const args = process.argv.slice(2);
const modulePath = args.find((a) => !a.startsWith('--'));
const stdin = (args.find((a) => a.startsWith('--stdin=')) || '--stdin=').slice(8);
const maxFrames = Number((args.find((a) => a.startsWith('--frames=')) || '--frames=100000').slice(9));

if (!modulePath) {
  console.error('usage: run.mjs <module.wasm> [--stdin=keys] [--frames=n]');
  process.exit(2);
}

// Files, backed by the real filesystem: a headless build reads its assets and
// writes out.ppm exactly where the native headless binary does.
class NodeFiles {
  constructor() { this.open = new Map(); this.next = 1; }

  fopen(path, mode) {
    const h = this.next++;
    if (mode.includes('w') || mode.includes('a')) {
      this.open.set(h, { path, write: true, chunks: [], size: 0, pos: 0 });
      return h;
    }
    if (!existsSync(path)) return 0;
    this.open.set(h, { path, write: false, data: new Uint8Array(readFileSync(path)), pos: 0 });
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
    f.chunks.push(src.slice(0, n));
    f.size += n; f.pos += n;
    return n;
  }

  fclose(h) {
    const f = this.open.get(h);
    if (!f) return;
    if (f.write) {
      const all = new Uint8Array(f.size);
      let at = 0;
      for (const c of f.chunks) { all.set(c, at); at += c.length; }
      writeFileSync(f.path, all);
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

  ftell(h) { const f = this.open.get(h); return f ? f.pos : -1; }
}

const host = new Host({ files: new NodeFiles(), stdin });
const { instance } = await WebAssembly.instantiate(readFileSync(modulePath), { env: host.imports() });
host.bind(instance.exports.memory);

const { ludic_boot, ludic_frame, ludic_alive, ludic_teardown } = instance.exports;

let frames = 0;
try {
  ludic_boot();
  while (host.running && ludic_alive() && frames < maxFrames) { ludic_frame(); frames++; }
  ludic_teardown();
} catch (e) {
  if (!(e instanceof ExitSignal)) throw e;
}
host.flush();

if (frames >= maxFrames) {
  console.error(`ludic-web: stopped after ${maxFrames} frames (the game never ended)`);
  process.exit(1);
}
process.exit(host.exitCode ?? 0);
