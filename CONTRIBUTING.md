# Contributing to Ludic

Thanks for your interest in Ludic — an AoT-**compiled** game language with an
ECS core, a deterministic fixed-point runtime, and a native 2D backend. This
guide covers the unusual bit: Ludic is **self-hosted**, so the compiler, the
runtime, and the tooling are all written in Ludic and built by Ludic.

## Prerequisites

- `clang` (or another C compiler) — used **once** to assemble the checked-in
  LLVM-IR seed into the first `ludicc`, and thereafter only to assemble IR and
  link. No C is generated in a build.
- LLVM (for the web/wasm target: `brew install llvm lld`).
- macOS for the windowed Cocoa backend; headless PPM rendering works anywhere.

## First build (bootstrap)

From a clean checkout, one line lifts the toolchain off the seed:

```bash
clang selfhost/ludicc.seed.ll -o bin/ludicc && bin/ludicc tools/x/main.ludic -o bin/x
```

That gives you `bin/x`, the Ludic task runner that replaces every build/test
shell script in the repo. From then on it builds everything — including itself:

```bash
bin/x build          # rebuild the whole toolchain into bin/ (ludicc, ludic, x, ludic-fmt, ludic-lsp)
bin/x help           # list every command
```

Always run `x` from the repository root, so `assets/` and `selfhost/` resolve.

## The development loop

When you change the compiler or runtime, prove the self-hosting fixpoint still
holds before you push:

```bash
bin/x reseed          # regenerate selfhost/ludicc.seed.ll after a compiler change
bin/x bootstrap-cfree # rebuild the compiler from the seed with NO C compiler in the loop
bin/x test            # the full regression suite
```

Other useful targets:

```bash
bin/x app <file.ludic> [--headless]   # compile a program to a native app in build/
bin/x selfhost-test                   # correctness + bootstrap fixpoints
bin/x test-tools                      # the editor-toolchain suite (ludic-fmt, ludic-lsp)
bin/x clean                           # remove build/, out.ppm and stray artifacts
```

## Adding to the standard library

The stdlib lives in the runtime (`runtime/`) and is surfaced as namespaces
(`Math.*`, `Crypto.*`, `DateTime.*`, `Screen.*`, …). When you add a symbol:

1. Implement it in the runtime / emitter as appropriate.
2. Document it: add one Markdown file per symbol under `docs/language/<namespace>/`
   and register its id in `tools/docgen/inventory.json`. Each documented
   namespace gets exactly **one** directory (the docs check enforces this).
3. Add or extend an example under `examples/` and a case in the test suite.
4. Run `python3 tools/docgen/gen.py && python3 tools/docgen/check.py` — the
   check fails if any inventory symbol lacks a page or is still seed text.

## Conventions

- **Commits:** [Conventional Commits](https://www.conventionalcommits.org) —
  `type(scope): summary`, e.g. `feat(stdlib): …`, `fix(emit): …`,
  `ci(docs): …`, `docs(readme): …`. Keep the summary imperative and under ~72
  chars.
- **Formatting:** `ludic-fmt` is the source of truth (2-space indent, LF, UTF-8);
  the repo `.editorconfig` mirrors it. Run `bin/ludic-fmt` on files you touch.
- **Code structure:** one job per file. Split large files by concern into
  subfolders rather than growing a single 500+-line module (see how `selfhost/`
  and `runtime/` are organised).
- **Language of the toolchain:** new runtime and tooling are written in **Ludic**,
  not C, Python, or JS. The only non-Ludic pieces are the LLVM-IR seed
  (`selfhost/ludicc.seed.ll`), the hand-written `runtime/native/cocoa.ll` /
  `runtime/web/wasm.ll` shims, and the legacy Python docgen (being ported).

## Pull requests

- Base your branch on `main`.
- Ensure `bin/x test` (and `bin/x bootstrap-cfree` for compiler/runtime changes)
  pass, and that `ludic-fmt` leaves your files unchanged.
- Fill in the PR template checklist. Reference the issue you close with
  `Closes #NN` in the description or a commit message.

## Reporting issues

Use the templates under [`.forgejo/issue_template/`](.forgejo/issue_template):
a **bug report**, a **proposal** (new stdlib/language surface), or a
**cleanup/DX** task. Choose the one that fits and fill in the sections.

By participating you agree to the [Code of Conduct](CODE_OF_CONDUCT.md).
