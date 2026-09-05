bump: minor
type: feat
**One command installs Ludic, and `ludic` is the command you use.** Getting
started no longer means cloning the repository and learning a task runner called
`x`.

- **`curl -fsSL https://workshopsoft.pages.workshopsoft.io/ludic/install.sh | sh`** installs a complete
  toolchain — compiler, CLI, engine runtime, bundled `ludic.*` packages,
  formatter and language server — into `~/.ludic` and puts it on your `PATH`.
  Prebuilt artifacts are verified against a published checksum; where none
  exists for the platform, the installer bootstraps from the compiler's own IR
  seed with clang. Uninstalling is `rm -rf ~/.ludic`, and `ludic upgrade`
  re-runs the same script.
- **`ludic` replaces `x`** and is the only command a user of the language meets:
  `ludic new` scaffolds a project that builds and plays as it stands, `ludic
  run` / `ludic build` compile it (`--headless` for a deterministic render),
  `ludic test` runs every `test` block in the project, and `ludic add` / `get` /
  `update` / `verify` / `vendor` drive packages. `ludic fmt` and `ludic lsp` are
  the formatter and language server, so an editor needs no path configuration.
  `ludic doctor` reports whether the install is complete and usable.
- **The toolchain's own tasks moved under `ludic dev`** — `dev build`, `dev
  test`, `dev reseed`, `dev bootstrap-cfree`, `dev docs-gen`, `dev release` and
  the rest are unchanged apart from the namespace. `bin/x` is gone; the
  bootstrap is now `clang selfhost/ludicc.seed.ll -o bin/ludicc && bin/ludicc
  tools/ludic-cli/main.ludic -o bin/ludic`.
- **An install root is a first-class layout.** The compiler derives it from its
  own location — the parent of its `bin/` directory — so `~/.ludic` and a repo
  checkout are the same shape, and `$LUDIC_HOME` is no longer needed to build a
  windowed game outside the repo. The bundled `ludic.*` packages resolve from
  `$LUDIC_HOME/packages`, so `import "ludic.core/components.ludic"` works with no
  `ludic_modules/` to set up. Release artifacts are complete install roots
  (`bin/` beside `runtime/`, `packages/` and `VERSION`) rather than bare
  binaries, and the installer ships with the documentation site it is served
  from.
