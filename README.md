# Ludic

An AI-first, ahead-of-time **compiled** game language with an ECS core, a
deterministic fixed-point runtime, and a native 2D backend. `ludicc` lowers
Ludic to LLVM IR itself and emits a native binary — **and `ludicc` is itself
written in Ludic.**

```
  .ludic  ──►  ludicc  ──►  LLVM IR  ──►  object  ──►  native binary
             (in Ludic)
```

**No C is generated, compiled or linked anywhere in a build.** There is no
interpreter, no transpiler, and no C runtime: the framebuffer, sprites, PNG
decoding, TrueType text, the retained UI, the registers and the RNG are all
written in Ludic (`runtime/native/*.ludic`), and the macOS window is
hand-written LLVM IR (`runtime/native/cocoa.ll`). Beneath that sits only the
platform's own ABI — malloc, fwrite, objc_msgSend, CoreGraphics — reached by
compiler intrinsics, the same floor Rust and Swift stand on.

**The compiler is written in Ludic.** `selfhost/*.ludic` is a Ludic compiler —
lexer, parser and LLVM-IR backend — that compiles every example (including the
6-file JRPG) to the byte-exact same binary the original C compiler produced, and
compiles **its own source** to a fixpoint. It is built from a checked-in IR seed
(`selfhost/ludicc.seed.ll`) with clang alone; run `./selfhost/bootstrap-cfree.sh`
to rebuild it with no C compiler in the loop. The former C compiler is gone.

Neither the compiler nor the games are C. Beneath both sits only the platform's
own ABI — malloc, fwrite, objc_msgSend, CoreGraphics — reached by intrinsics, the
same floor Rust and Swift stand on. (The wasm/cross-compile/shared-library driver
paths lived in the old C compiler and are not yet re-implemented on the
self-hosted native toolchain.)

## Layout

| Path | What it is |
|------|-----------|
| `selfhost/*.ludic`     | **the compiler, written in Ludic** — lexer, parser, and the LLVM-IR backend (ECS storage, queries, spawn, `match`/`machine`, UI, scenes, save/load, fixed-point). Concatenated by `selfhost/build.sh`; built from `selfhost/ludicc.seed.ll` |
| `selfhost/bootstrap-cfree.sh` | rebuild the compiler from the IR seed with **no C compiler**, and prove it reproduces its own IR |
| `runtime/native/core.ludic` | the runtime written *in Ludic* for the native path (framebuffer, text, registers, RNG, input) |
| `COMPILING.md`         | the native pipeline: `ludicc → LLVM IR → exe/dylib`, `module`/`export`, cross-compilation, `rt_*` intrinsics |
| `runtime/native/image.ludic` | PNG decoding, images, sprites, alpha blending and 9-slice — in Ludic |
| `runtime/native/inflate.ludic` | DEFLATE decompression (RFC 1951), so PNG needs no zlib on any target |
| `runtime/native/truetype.ludic` | from-scratch TrueType loader + antialiased glyph rasterizer, in Q16.16 |
| `runtime/native/ui.ludic` | retained UI widget tree: layout, 9-slice, focus, events — in Ludic |
| `runtime/native/cocoa.ll` | the macOS window, written in LLVM IR (Objective-C runtime + CoreGraphics via their C ABI) |
| `runtime/web/wasm.ll`  | the web's platform layer in LLVM IR: the allocator, bulk memory and strings, since wasm32 has no libc |
| `runtime/web/platform.js` | the browser's window — the same five `win_*` functions `cocoa.ll` implements, against a `<canvas>` |
| `runtime/web/index.html` | the page a web build is served from |
| `tools/ludic-web/run.mjs` | runs a headless wasm build under Node, so native and wasm output can be diffed |
| `examples/chronorift.ludic` | the JRPG written in Ludic (multi-file via `import`, archetype-based) |
| `examples/menu.ludic`  | a retained-UI title screen (9-slice, TrueType, focusable buttons) |
| `examples/snake.ludic` | a second, unrelated game — proves the language is general (same toolchain, no engine hardcoding) |
| `build.sh`             | `./build.sh examples/<name>.ludic` |
| `test.sh`              | regression suite: builds the compiler, compiles/runs all examples, checks save/load + diagnostics (`./test.sh`) |
| `tools/ludic-tools/`   | the editor toolchain, in C: `ludic-fmt` (source formatter) and `ludic-lsp` (language server) — one lexer and one vocabulary shared by both |
| `tools/editors/`       | plugins for VS Code and JetBrains, plus configuration for Neovim, Helix, Emacs, Sublime and Zed ([README](tools/editors/README.md)) |
| `tools/test-tools.sh`  | regression suite for the toolchain: proves formatting never changes a program, drives the language server over real LSP traffic |

## Build & run

`ludicc` compiles Ludic straight to machine code via LLVM IR. See
**[COMPILING.md](COMPILING.md)** for the pipeline, shared libraries
(`--shared`), cross-compilation and the runtime protocol.

```bash
./build.sh examples/chronorift.ludic
./build/chronorift            # opens a native window
```

Headless render (for testing / CI):

```bash
./build.sh examples/chronorift.ludic --headless
printf 'ddddwww' | ./build/chronorift_headless   # writes out.ppm
sips -s format png out.ppm --out frame.png
```

A `module` compiles to a shared library instead of a program:

```bash
./build.sh examples/lib/combat.ludic --lib        # -> build/libcombat.dylib
```

In a browser:

```bash
./build.sh examples/chronorift.ludic --web         # -> build/web/
python3 -m http.server -d build/web 8000          # open http://localhost:8000/
```

`build/web/` is a self-contained 116 KB directory — the 42 KB module, the loader,
a page, and the sprites the compiler saw the game name. Copy it to any static
host and it runs; it needs no server-side anything and no special headers. Saves
go to `localStorage`, so `save()`/`load()` survive a reload.

A wasm build needs an LLVM with the WebAssembly backend and `wasm-ld` — Linux
`clang`/`lld` have both, Apple's clang has neither (`brew install llvm lld`).
See **[COMPILING.md](COMPILING.md#the-web)** for the pipeline, who owns the frame
loop, and how assets are bundled.

## Editor support

```bash
./tools/build-tools.sh          # -> build/ludic-fmt, build/ludic-lsp
```

`ludic-lsp` speaks LSP 3.17 over stdio, so one binary serves every editor:
completion that knows whether you are after a `.`, inside a `query [...]` or in
a `ui` block; diagnostics from the compiler itself; go-to-definition and rename
across `import`ed files; comment-preserving formatting. `ludic-fmt` is the same
formatter as a CLI, for pre-commit hooks and CI.

Plugins for **VS Code** and **JetBrains IDEs** (Community editions included) and
drop-in configuration for Neovim, Helix, Emacs, Sublime and Zed are in
[`tools/editors/`](tools/editors/README.md). Both tools also understand
```` ```ludic ```` fences in Markdown, so this file and `LANGUAGE.md` get the
same highlighting, checking and formatting as the source tree.

## Language features implemented

- `component` (typed fields + defaults), `system` (`phase`, `@annotations`,
  `reads`/`writes` clauses), `const`, `fn` (with `requires`/`ensures` parsed).
- `archetype` — named entity **kinds** (bundles of components); identity is one
  int per entity, replacing empty tag components. Filter with `{Kind}`.
- `import "file"` — multi-file programs (fragments spliced in, include-guarded,
  per-file diagnostics).
- ECS queries: `for (a, b) in query [A, B, {Tag}] where <expr> { … }`.
- `spawn`/`despawn` with entity-slot reuse; nested queries.
- Control flow: `if`/`else`, `when`, `while`, numeric `for i in a .. b`.
- Types: `int`, `fixed` (Q16.16, with correct `*`/`/` lowering), `bool`,
  `entity`, `str`. Fixed-point vs int arithmetic is resolved by the typechecker.
- Deterministic seeded RNG; `save()`/`load()` snapshot of the whole ECS World.
- 2D primitives: `clear`, `fill_rect`, `frame_rect`, `put_px`, `present`, `key`.
- TrueType text (`font_load`, `text_ttf`) with full Unicode + anti-aliasing;
  arbitrary-size images + `draw_9slice`.
- `ui` — a retained widget tree declared as data (panels, labels, buttons,
  images; layout, 9-slice skins, keyboard focus + click events).
- `match` / `machine`+`state`+`become` — dispatch and state machines.
- `scene` / `layer` / `enter` — mutually-exclusive game states, each with
  `on enter`/`on exit` hooks and layered systems (layer order = draw order).
- `var` — typed module-level state, included in save/load snapshots.
- `module` + `export fn` — compile a .ludic file to a shared library whose
  exported functions are ordinary C-ABI symbols.
- `extern fn … = "symbol"` — call any C-ABI library, Ludic or otherwise.
- `--target wasm32-unknown-unknown` — the same game in a browser: the runtime,
  the ECS and the graphics stack compiled to wasm, rendering frames identical to
  the native build's.

## The game: Chrono Rift

A playable co-op JRPG in `examples/chronorift.ludic`, using CC0
[Kenney](https://kenney.nl) sprites (Tiny Town + Tiny Dungeon), decoded from
PNG at runtime by the Ludic-written PNG/DEFLATE decoder — no zlib, no external
dependency on any target.

Controls:
- **Overworld:** `WASD` move, `K` save, `L` load.
- **Battle (local co-op):** Player 1 / Knight — `W`/`S` select, `Space` confirm.
  Player 2 / Mage — `I`/`K` select, `J` confirm. Each player takes their own
  turn each round (Attack / Defend / Run; Mage has Attack / Heal / Defend).

## Status

- [x] Compiler pipeline: Ludic → LLVM IR → native binary / shared library
- [x] No C generated, compiled or linked in a build; runtime written in Ludic
- [x] Cross-compilation to ELF (x86-64, aarch64) and Windows COFF
- [x] ECS runtime (components, systems, phases, queries, entity pooling)
- [x] Windowed 2D rendering (Cocoa driven from LLVM IR) + headless PPM verification
- [x] CC0 Kenney PNG sprites (`load_png`, decoder written in Ludic) + scrolling camera
- [x] Overworld: tilemap, movement, collision
- [x] Random encounters + turn-based battle (HP/MP, seeded-RNG damage)
- [x] Party + **local co-op** (P1 Knight, P2 Mage, per-player turns)
- [x] Leveling (XP → stat growth) and game-over / respawn
- [x] **Self-hosting**: a Ludic-written compiler compiles its own source to a byte-exact fixpoint, and rebuilds itself from a checked-in IR seed with no C compiler in the loop (`selfhost/`, `./selfhost/bootstrap-cfree.sh`)
- [x] Snapshot save / load (full ECS World)
- [x] Two maps (overworld + dungeon) with map switching via the arch
- [x] Boss encounter (Rift Warden) + victory condition
- [x] Item shop (gold → potions) at the house; potions usable in battle (Knight ITEM)
- [ ] More skills / enemy variety (future)
