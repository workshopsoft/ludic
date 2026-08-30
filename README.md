# Ludic

Ludic is an **ahead-of-time compiled** language for 2D games with an
entity-component core, a deterministic fixed-point runtime, and its graphics
stack built into the language. `ludicc` lowers Ludic straight to LLVM IR and
emits a native binary — and **`ludicc` is itself written in Ludic**, compiles
its own source to a byte-exact fixpoint, and rebuilds from a checked-in IR seed
with **no C compiler in the loop**.

```
  .ludic  ──►  ludicc  ──►  LLVM IR  ──►  object  ──►  native binary
             (in Ludic)
```

**No C is generated, compiled or linked in a build.** No interpreter, no
transpiler, no C runtime: the framebuffer, sprites, PNG/DEFLATE decoding,
TrueType text, the retained UI, the registers and the RNG are all written in
Ludic (`runtime/native/*.ludic`); only the window seam — five `win_*` functions
— is hand-written LLVM IR against the platform ABI (`runtime/native/cocoa.ll`),
the same floor Rust and Swift stand on.

## Backends

| Backend | Status |
|---|---|
| **Native 2D** (macOS/Cocoa window; headless render for CI) | **Shipping** — the default `bin/x app` target. |
| **Web / wasm32** | **In progress.** The browser platform layer is in-tree and documented — `runtime/web/` (the `<canvas>` window `platform.js`, the libc-free `wasm.ll` floor) and a Node harness that diffs native vs. wasm frame-for-frame (`tools/ludic-web/run.mjs`). Emitting wasm was a capability of the retired C compiler and is **not yet re-wired on the self-hosted toolchain**; see [COMPILING.md](COMPILING.md). |

The same is true of `--target` cross-compilation and `--shared` libraries: both
are designed and documented, both lived in the old C compiler, and both are
pending re-implementation on the self-hosted native toolchain.

## Quick start

`bin/x` is the project's task runner — one native binary, written in Ludic and
compiled by Ludic, that replaces every build/test/bootstrap shell script.
Bootstrap it once from a clean checkout (the only step Ludic can't do for
itself, since compiling Ludic needs a compiler) with clang alone:

```bash
clang selfhost/ludicc.seed.ll -o bin/ludicc && bin/ludicc tools/x/main.ludic -o bin/x
```

Then build the whole toolchain and run a game:

```bash
bin/x build                                  # -> bin/{ludicc,ludic,x,ludic-fmt,ludic-lsp}
bin/x app examples/games/snake.ludic         # compile + open a native window
./build/snake
```

Render a frame headlessly (what CI checks) — output lands in `build/`, never the
repo root:

```bash
bin/x app examples/games/chronorift.ludic --headless
mkdir -p build && printf 'ddddwww' | ./build/chronorift_headless   # writes build/out.ppm
sips -s format png build/out.ppm --out frame.png
```

Run the suites:

```bash
bin/x test            # full regression: compiler builds from seed, every example, golden renders
bin/x selfhost-test   # correctness + the self-hosting / C-free bootstrap fixpoints
bin/x help            # every command
```

## Layout

| Path | What it is |
|------|-----------|
| [`selfhost/*.ludic`](selfhost/) | **the compiler, written in Ludic** — lexer, parser, and the LLVM-IR backend (ECS storage, queries, spawn, `match`/`machine`, UI, scenes, save/load, fixed-point). Built from `selfhost/ludicc.seed.ll` with clang alone. |
| [`selfhost/golden/renders.sha256`](selfhost/golden/renders.sha256) | text baseline of render-output hashes (replaces binary `.ppm` fixtures); regenerate with `bin/x golden`. |
| [`tools/x/*.ludic`](tools/x/) | **the task runner, written in Ludic** — one binary (`bin/x`) that builds, tests, bootstraps and reseeds the project, replacing every shell script. |
| [`runtime/native/`](runtime/native/) | the runtime **in Ludic** for the native path: `core` (framebuffer, input, RNG), `image`/`inflate` (PNG + DEFLATE, no zlib), `truetype` (glyph rasterizer), `ui` (retained widget tree); plus `cocoa.ll`, the macOS window seam in LLVM IR. |
| [`runtime/web/`](runtime/web/) | the browser platform layer: `platform.js` (the `<canvas>` window), `wasm.ll` (the libc-free floor), `index.html`. |
| [`examples/`](examples/README.md) | the example tour, grouped by intent — `games/`, `rendering/`, `ecs/`, `events/`, `networking/`, `lang/`, `library/`. See [examples/README.md](examples/README.md). |
| [`tools/ludic-tools/`](tools/ludic-tools/) | the editor toolchain **in Ludic**: `ludic-fmt` (formatter) and `ludic-lsp` (language server) — one lexer, one vocabulary shared by both. |
| [`tools/editors/`](tools/editors/README.md) | plugins for VS Code and JetBrains, plus config for Neovim, Helix, Emacs, Sublime and Zed. |
| [`docs/`](docs/) | the per-symbol API reference, regenerated into the docs site. |
| [`COMPILING.md`](COMPILING.md) | the native pipeline: `ludicc → LLVM IR → exe`, the `rt_*` runtime protocol, and the (pending) wasm/cross-compile/shared-library paths. |

The design and roadmap material lives on the **[wiki](https://git.workshopsoft.io/workshopsoft/ludic/wiki)**:
the [Events](https://git.workshopsoft.io/workshopsoft/ludic/wiki/Design/Events),
[Networking](https://git.workshopsoft.io/workshopsoft/ludic/wiki/Design/Networking),
[Scenes](https://git.workshopsoft.io/workshopsoft/ludic/wiki/Design/Scenes),
[Lifecycle](https://git.workshopsoft.io/workshopsoft/ludic/wiki/Design/Lifecycle),
[Mobile](https://git.workshopsoft.io/workshopsoft/ludic/wiki/Design/Mobile) and
[Syntax-redesign](https://git.workshopsoft.io/workshopsoft/ludic/wiki/Design/Syntax-Redesign)
design records, the [Bootstrap deep-dive](https://git.workshopsoft.io/workshopsoft/ludic/wiki/Bootstrap),
and the [Luanti roadmap](https://git.workshopsoft.io/workshopsoft/ludic/wiki/Roadmap/Luanti).
The root keeps only this README plus the two user-facing references,
[`LANGUAGE.md`](LANGUAGE.md) and [`COMPILING.md`](COMPILING.md).

## Language at a glance

- `program` / `property` (typed fields + defaults) / `model` (named entity kinds)
  / `system` (`phase`, `@annotations`, `reads`/`writes`).
- ECS queries `for (a, b) in query [A, B, {Tag}] where <expr> { … }`,
  `spawn`/`despawn` with slot reuse, `@`-driven lifecycle hooks.
- An **event bus** (`event` / `emit` / `@On`, cancellable, `@Public` promotion)
  and **networking** primitives (`@Sync`, ownership, RPCs) over a built-in
  loopback transport — all deterministic, all pure Ludic.
- `scene` / `layer` / `become`, `match` / `machine` + `state`.
- Types `int`, `fixed` (Q16.16), `bool`, `entity`, `str`, `byte`, typed buffers;
  a growing namespaced **standard library** (`Math`, `Vector`, `Time`/`Date`/
  `Duration`/`Clock`, `Random`, `Hash`, `Crypto`, sorting, …).
- Deterministic seeded RNG and `save()`/`load()` snapshot of the whole World.
- Built-in 2D: framebuffer primitives, PNG sprites, TrueType text, 9-slice, and
  a retained `ui` widget tree declared as data.

See [LANGUAGE.md](LANGUAGE.md) for the full reference, and
[examples/README.md](examples/README.md) for runnable demos of each feature.

## Editor support

```bash
bin/x tools                     # -> bin/ludic-fmt, bin/ludic-lsp
```

`ludic-lsp` speaks LSP 3.17 over stdio, so one binary serves every editor:
context-aware completion, diagnostics from the compiler itself,
go-to-definition and rename across `import`ed files, and comment-preserving
formatting. `ludic-fmt` is the same formatter as a CLI, for pre-commit hooks and
CI. Both also understand ```` ```ludic ```` fences in Markdown. Plugins and
drop-in config are in [`tools/editors/`](tools/editors/README.md).

## Chrono Rift — the flagship game

[`examples/games/chronorift.ludic`](examples/games/chronorift.ludic) is a
playable co-op JRPG — overworld, dungeon, random encounters, a turn-based co-op
battle, a boss, an item shop and snapshot save/load — split across modules under
[`games/chronorift/`](examples/games/chronorift/). Its art is CC0
[Kenney](https://kenney.nl) sprites, decoded from PNG at runtime by the
Ludic-written PNG/DEFLATE decoder — no zlib, no external dependency.

- **Overworld:** `WASD` move, `K` save, `L` load.
- **Battle (local co-op):** P1/Knight `W`/`S` select, `Space` confirm;
  P2/Mage `I`/`K` select, `J` confirm.

## Status & roadmap

The compiler self-hosts to a byte-exact fixpoint and rebuilds from its IR seed
with no C compiler; the ECS runtime, windowed + headless 2D rendering, the event
bus, the deterministic networking stack, scenes, and save/load are all in place
and covered by `bin/x test`. CI gates every push and PR on the build, the test
suites, and that C-free fixpoint. The toolchain is versioned with SemVer
(`ludicc --version`); releases and the `CHANGELOG.md` are cut from changesets by
`x release`.

Active work and proposals — the standard library, a fuller type system,
rendering/animation/lighting extras, input, filesystem/IO, testing, and
re-wiring the web/wasm and cross-compile backends — are tracked as issues, not
inlined here:

- **Issues & proposals:** <https://git.workshopsoft.io/workshopsoft/ludic/issues>
- **Docs site (API reference):** <https://workshopsoft.pages.workshopsoft.io/ludic/>
- **Wiki (design & roadmap):** <https://git.workshopsoft.io/workshopsoft/ludic/wiki>

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the development loop
(`bin/x reseed` → `bin/x bootstrap-cfree` → `bin/x test`), the code and commit
conventions, and how the bootstrap fixpoint works. Issue and pull-request
templates live under [`.forgejo/`](.forgejo/).

## License

The Ludic compiler and runtime source are licensed under the
[Apache License 2.0](LICENSE) (`SPDX-License-Identifier: Apache-2.0`) — a
permissive license with an explicit patent grant.

The bundled [Kenney](https://kenney.nl) art under `assets/kenney/` is
third-party and released under **CC0 1.0** (public domain); each pack keeps its
own `License.txt`. Code and assets are licensed separately: Apache-2.0 covers
the source, not the art.
