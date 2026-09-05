# Ludic

A compiled language for 2D games. The entity-component system is part of the
syntax, the runtime is deterministic fixed-point, and `ludicc` lowers Ludic
straight to LLVM IR — **no C is generated, compiled or linked in a build.**

The compiler is written in Ludic. It compiles its own source to a byte-exact
fixpoint and rebuilds from a checked-in IR seed with clang alone; CI asserts
that on every push.

- **Documentation:** <https://workshopsoft.pages.workshopsoft.io/ludic/>
- **API reference:** <https://workshopsoft.pages.workshopsoft.io/ludic/api.html>
- **Issues:** <https://git.workshopsoft.io/workshopsoft/ludic/issues>

```ludic
program Hello {

  property Position { column: int = 0, row: int = 0 }
  property Velocity { delta_x: int = 0, delta_y: int = 0 }

  handler SpawnEnemies phase Start {
    spawn Enemy { Position { column: 3, row: 4 },  Velocity { delta_x: 1, delta_y: 0 } }
    spawn Enemy { Position { column: 10, row: 2 }, Velocity { delta_x: 0, delta_y: 1 } }
  }

  # a handler declares the entities it touches; the body runs
  # once per match, with each property bound by name.
  @Queries(these: [Position, Velocity])
  handler AdvancePositions phase FixedUpdate {
    Position.column += Velocity.delta_x
    Position.row    += Velocity.delta_y
  }
}
```

## Getting started

`bin/x` is the project's task runner: one native binary, written in Ludic and
compiled by Ludic, that replaces every build and test script. Bootstrapping it
is the only step Ludic cannot do for itself, since compiling Ludic needs a
compiler — clang assembles the checked-in IR seed:

```bash
mkdir -p bin && clang selfhost/ludicc.seed.ll -o bin/ludicc && bin/ludicc tools/x/main.ludic -o bin/x
```

Then build the toolchain and run a game:

```bash
bin/x build                             # -> bin/{ludicc,ludic,x,ludic-fmt,ludic-lsp}
bin/x app examples/games/snake.ludic    # compile and open a native window
./build/snake
```

Rendering is deterministic, so a frame can be produced without a window — this
is what CI diffs:

```bash
bin/x app examples/games/snake.ludic --headless
printf 'ddddwww' | ./build/snake_headless    # writes build/out.ppm
```

`bin/x help` lists every command. [`examples/`](examples/README.md) is a tour
grouped by intent: games, rendering, ECS, events, networking, language features
and the standard library.

## The language

- **ECS in the syntax.** `property`, `model` and `handler` are keywords. Query
  with `for (a, b) in query [A, B, {Tag}] where <expr> { … }`; `spawn` and
  `despawn` recycle entity slots; `@`-annotations drive lifecycle hooks.
- **Deterministic by construction.** Q16.16 `fixed` arithmetic and a seeded RNG
  give the same frame byte-for-byte on every run — the basis for replays,
  lockstep netcode and golden-image tests.
- **Scenes and state machines.** `scene` / `layer` / `become` model
  mutually-exclusive game states with enter and exit hooks; `match` / `machine`
  / `state` handle dispatch and per-entity FSMs.
- **Events and networking.** A cancellable event bus (`event` / `emit` / `@On`)
  and networking primitives (`@Sync`, ownership, RPCs) over a built-in transport.
- **Batteries in the language.** Framebuffer primitives, PNG sprites, TrueType
  text and a retained `ui` widget tree declared as data, plus a namespaced
  standard library (`Math`, `Text`, `List`, `Random`, `Crypto`, `Tiled`, …).
- **Whole-world snapshots.** `save()` and `load()` serialize every entity,
  property and program `var` in one call.

[LANGUAGE.md](LANGUAGE.md) is the full reference; the
[API reference](https://workshopsoft.pages.workshopsoft.io/ludic/api.html)
documents every symbol on its own page.

## Packages

Dependencies are identified by URL, resolved with minimal version selection, and
cached in a content-addressed store:

```bash
bin/x add git.workshopsoft.io/user/pkg   # resolve, fetch, link into ludic_modules/
bin/x get                                # install from package.ludic, write the lock
bin/x verify                             # check locked packages against the store
```

See [`docs/PACKAGES.md`](docs/PACKAGES.md) for the manifest and lockfile model.

## Editor support

```bash
bin/x tools    # -> bin/ludic-fmt, bin/ludic-lsp
```

`ludic-lsp` speaks LSP 3.17 over stdio, so one binary serves every editor:
completion, diagnostics from the compiler itself, go-to-definition and rename
across imports, and comment-preserving formatting. `ludic-fmt` is the same
formatter as a CLI, for pre-commit hooks. Both understand ```` ```ludic ````
fences in Markdown. Plugins and drop-in config for VS Code, JetBrains, Neovim,
Helix, Emacs, Sublime and Zed are in [`tools/editors/`](tools/editors/README.md).

## Status

The native 2D backend ships: a Cocoa window on macOS, a headless renderer for
CI, and the whole runtime — framebuffer, PNG/DEFLATE decoding, TrueType
rasterizer, retained UI, RNG — written in Ludic under
[`runtime/native/`](runtime/native/). Only the window seam (`win_*`: window,
keys, mouse, cursor, gamepad, touch) is hand-written LLVM IR against the
platform ABI, the same floor Rust and Swift stand on.

The **web/wasm32 backend is not currently available.** The browser platform
layer is in-tree under [`runtime/web/`](runtime/web/), but emitting wasm was a
capability of the retired C compiler and has not been re-wired on the
self-hosted toolchain. `--target` cross-compilation and `--shared` libraries are
in the same position. See [COMPILING.md](COMPILING.md).

Releases follow SemVer and are cut from changesets by `x release`, then built
and published by CI from the tag; see [CHANGELOG.md](CHANGELOG.md).

## Contributing

[CONTRIBUTING.md](CONTRIBUTING.md) covers the development loop, the commit and
code conventions, how the bootstrap fixpoint works, and what a self-hosted CI
runner needs. Issue and pull-request templates are under
[`.forgejo/`](.forgejo/).

## License

The compiler and runtime are licensed under the
[Apache License 2.0](LICENSE) (`SPDX-License-Identifier: Apache-2.0`).

The bundled [Kenney](https://kenney.nl) art under `assets/kenney/` is
third-party and released under **CC0 1.0**; each pack keeps its own
`License.txt`. Code and assets are licensed separately — Apache-2.0 covers the
source, not the art.
