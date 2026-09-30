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

Install the toolchain — the compiler, the `ludic` CLI, the engine runtime, the
formatter and the language server — with one command:

```bash
curl -fsSL https://workshopsoft.pages.workshopsoft.io/ludic/install.sh | sh
```

It installs into `~/.ludic` and puts `~/.ludic/bin` on your `PATH` in every
shell — the PATH line lives in `~/.ludic/env`, sourced from `~/.profile`,
`~/.zshenv` and your bash or fish config. Nothing else on the machine is touched;
uninstalling is `rm -rf ~/.ludic` and deleting those two-line blocks. Where a
prebuilt toolchain exists for your platform it is downloaded and verified against
a published checksum; where it does not, the installer bootstraps from the
compiler's own IR seed with clang. Either way you need clang (or Xcode's Command
Line Tools) to link, since Ludic emits LLVM IR and links it natively.

Then make a game:

```bash
ludic new mygame
cd mygame
ludic run            # compiles src/main.ludic and opens a native window
```

`ludic new` writes a manifest, a program that already moves something on screen,
and a test. `ludic templates` lists the other starters (`third-person`, `first-person`,
`2d-platformer`, `top-down`); `ludic new mygame --template top-down` copies one. `ludic build` stops at the binary; `ludic bundle` goes on to the
thing you can actually give someone. Rendering is deterministic, so a frame can
be produced without a window, which is what CI diffs:

```bash
ludic test
ludic build --headless
printf 'ddddwww' | ./build/mygame_headless    # writes build/out.ppm
```

`ludic help` lists every command, and `ludic doctor` checks the install.
[`examples/`](examples/README.md) is a tour grouped by intent: games, rendering,
ECS, events, networking, language features and the standard library — compile any
of them with `ludic build examples/games/snake.ludic`.

### Building from a checkout

Contributors also get `ludic-dev`, a second binary carrying the toolchain's own
tasks — building the compiler, the suites, the docs site, releases. It is built
from a checkout and is not part of an install, so nothing a user runs is mixed
up with it. Bootstrapping is the only step Ludic cannot do for itself, since
compiling Ludic needs a compiler — clang assembles the checked-in IR seed, and
that compiler builds the rest:

```bash
mkdir -p bin && clang selfhost/ludicc.seed.ll -o bin/ludicc
bin/ludicc --unsafe --globals tools/ludic-cli/dev.ludic -o bin/ludic-dev
bin/ludic-dev build     # -> bin/{ludicc,ludic,ludic-dev,ludic-fmt,ludic-lsp}
bin/ludic-dev test      # the regression suite
```

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

## Shipping

A built binary is a program, not an application: it opens its assets by a path
relative to the working directory, so it runs from the project root and nowhere
else, and it wears the generic executable icon.

```bash
ludic pack      # every asset the game opens, into one .lpak
ludic bundle    # ...and that, the binary, an icon and the metadata, as a .app
```

Nothing about how the game is written changes. `gltf_load("assets/kit/hiker",
…)` reads a file during development and a run of bytes inside the bundle once
shipped, and cannot tell which — the pack is spliced in at `file_open`, the one
place every asset in a Ludic program comes through. A bundled game also gets a
boot splash it controls (`App.splash_hide()`) and a writable home under
Application Support, because Finder starts a `.app` at `/` where no save could
be written.

Without a pack beside it — which is every `ludic run` — nothing mounts and every
open goes to the filesystem exactly as before. See [docs/SHIPPING.md](docs/SHIPPING.md).

## Packages

Dependencies are identified by URL, resolved with minimal version selection, and
cached in a content-addressed store:

```bash
ludic add git.workshopsoft.io/user/pkg   # resolve, fetch, link into ludic_modules/
ludic get                                # install from package.ludic, write the lock
ludic remove git.workshopsoft.io/user/pkg   # the inverse of add
ludic verify                             # check locked packages against the store
```

The `ludic.*` packages — canonical ECS components, the gameplay, platformer,
RPG, shooter and NPC-AI modules — ship with the toolchain, so importing one needs
no fetch step at all.

See [`docs/PACKAGES.md`](docs/PACKAGES.md) for the manifest and lockfile model.

## Editor support

Editors spawn `ludic lsp`; the server ships with the toolchain, so there is
nothing extra to install. It speaks LSP 3.17 over stdio, so one binary serves
every editor: completion, diagnostics from the compiler itself, go-to-definition
and rename across imports, and comment-preserving formatting. `ludic fmt` runs
the same formatter as a CLI, for pre-commit hooks. Both understand
```` ```ludic ```` fences in Markdown. Plugins and drop-in config for VS Code, JetBrains, Neovim,
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

Releases follow SemVer and are cut from changesets by `ludic-dev release`, then built
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
