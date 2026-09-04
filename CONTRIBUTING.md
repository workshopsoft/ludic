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
4. Run `bin/x docs-gen --out build/pages && bin/x docs-check build/pages` — the
   check fails if any inventory symbol lacks a page or is still seed text.
5. Add a **changeset** for the user-facing change: a small file under
   [`changes/`](changes/README.md) with a `bump:` level and a one-line summary.
   The next release folds it into `CHANGELOG.md`.

## Versioning & releases

The toolchain is versioned with [SemVer](https://semver.org); `VERSION` is the
single source of truth and `ludicc --version` (or `x version`) reports it.

Releases are changeset-driven. Every user-facing change ships with a changeset
(step 5 above). To cut a release:

```bash
x release [major|minor|patch]   # omit the level to derive it from the changesets
```

That aggregates the pending changesets into a new `CHANGELOG.md` section, bumps
`VERSION`, commits `chore(release): vX.Y.Z`, and tags it. Add `--publish` (with
`FORGEJO_TOKEN` set) to also push and create the Forgejo release with source and
toolchain tarballs. The tag doubles as the reproducible bootstrap point: the
source archive plus its checked-in seed rebuild that exact toolchain.

## Conventions

- **Commits:** [Conventional Commits](https://www.conventionalcommits.org) —
  `type(scope): summary`, with an optional `!` before the colon for a breaking
  change. Keep the summary imperative and under ~72 chars. The types in use:

  | type | for |
  |------|-----|
  | `feat` | a new user-facing capability (a stdlib namespace, a language feature) |
  | `fix` | a bug fix |
  | `refactor` | a change that neither fixes a bug nor adds a feature |
  | `perf` | a performance improvement |
  | `docs` | documentation only (`docs/`, README, comments) |
  | `test` | tests only |
  | `build` | the build/bootstrap machinery (seed, `bin/x`, linking) |
  | `ci` | CI workflows under `.forgejo/` |
  | `style` | formatting/whitespace, no behaviour change |
  | `chore` | routine housekeeping with no other bucket |
  | `revert` | reverts a previous commit |

  Common scopes: `stdlib`, `lang`, `emit`, `runtime`, `tooling`, `docs`, `repo`.
  Reference the issue you close with a `Closes #NN` trailer.

- **Enforcement:** the hooks in [`tools/git-hooks/`](tools/git-hooks) enforce this
  locally, and the `commit-lint` CI job is the backstop. Turn the hooks on once,
  per clone:

  ```bash
  git config core.hooksPath tools/git-hooks
  ```

  That activates the `commit-msg` hook (rejects a non-conforming summary) and the
  `pre-commit` hook (rejects unformatted Ludic). Both read the same rules CI does,
  so a green local commit is a green CI run.

- **Formatting:** `ludic-fmt` is the source of truth (2-space indent, LF, UTF-8);
  the repo `.editorconfig` mirrors it. Run `bin/ludic-fmt -w` on files you touch.
  The contract CI enforces is *idempotence* — `ludic-fmt` re-run on its own output
  is a no-op — which leaves deliberate hand alignment in place; it is not a
  blanket `fmt(x) == x`.
- **Code structure:** one job per file. Split large files by concern into
  subfolders rather than growing a single 500+-line module (see how `selfhost/`
  and `runtime/` are organised).
- **Language of the toolchain:** new runtime and tooling are written in **Ludic**,
  not C, Python, or JS. The only non-Ludic pieces are the LLVM-IR seed
  (`selfhost/ludicc.seed.ll`), the hand-written `runtime/native/cocoa.ll` /
  `runtime/web/wasm.ll` shims, and the legacy Python docgen (being ported).

## Git history

The log has two eras: the pre-self-hosting `Phase Nx: …` / `Merge Phase Nx: …`
commits, and the Conventional Commits used since. **Decision: the old `Phase`
history stays as-is.** Rewriting already-pushed history (`filter-repo`/rebase) is
destructive and non-reversible for anyone who has cloned, and it buys little — so
we do not rewrite it. The convention is enforced *going forward* by the hook and
the `commit-lint` job (both skip merge commits, so the old merges never trip it).

When the versioning work lands (issue #33), the first release tag doubles as a
clean `v0` baseline that brackets the `Phase`-era prefix — the safe,
non-destructive version of "tidy the history" without touching a single commit.

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
