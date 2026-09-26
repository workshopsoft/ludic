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
mkdir -p bin && clang selfhost/ludicc.seed.ll -o bin/ludicc
bin/ludicc --unsafe --globals tools/ludic-cli/dev.ludic -o bin/ludic-dev
```

That gives you `bin/ludic-dev`, the contributor tool: it replaces every
build/test shell script in the repo and builds everything, including itself and
`bin/ludic`. It is deliberately a separate binary from the `ludic` users install
— that one carries none of these tasks and is never asked to.

```bash
bin/ludic-dev build      # the whole toolchain into bin/ (ludicc, ludic, ludic-dev, ludic-fmt, ludic-lsp)
bin/ludic-dev help       # every contributor task
bin/ludic help           # what a user of the language sees
```

Always run `ludic-dev` from the repository root, so `assets/` and `selfhost/`
resolve. (A checkout is also an install root: `bin/` beside `runtime/` and
`packages/`, exactly the shape `install.sh` lays down under `~/.ludic`, which is
why `bin/ludic` behaves there exactly as an installed one does.)

## The development loop

When you change the compiler or runtime, prove the self-hosting fixpoint still
holds before you push:

```bash
bin/ludic-dev reseed          # regenerate selfhost/ludicc.seed.ll after a compiler change
bin/ludic-dev bootstrap-cfree # rebuild the compiler from the seed with NO C compiler in the loop
bin/ludic-dev test            # the full regression suite
```

Other useful targets:

```bash
bin/ludic build <file.ludic> [--headless]     # compile a program to a native app in build/
bin/ludic-dev selfhost-test                   # correctness + bootstrap fixpoints
bin/ludic-dev test-tools                      # the editor-toolchain suite (ludic-fmt, ludic-lsp)
bin/ludic clean                               # remove build/, out.ppm and stray artifacts
```

## Adding to the standard library

The stdlib lives in the runtime (`runtime/`) and is surfaced as namespaces
(`Math.*`, `Crypto.*`, `DateTime.*`, `Screen.*`, …). When you add a symbol:

1. Implement it in the runtime / emitter as appropriate.
2. Document it: add one Markdown file per symbol under `docs/language/<namespace>/`
   and register its id in `tools/docgen/inventory.json`. Each documented
   namespace gets exactly **one** directory (the docs check enforces this).
3. Add or extend an example under `examples/` and a case in the test suite.
4. Run `bin/ludic-dev docs-gen --out build/pages && bin/ludic-dev docs-check build/pages` — the
   check fails if any inventory symbol lacks a page or is still seed text.
5. Add a **changeset** for the user-facing change: a small file under
   [`changes/`](changes/README.md) with a `bump:` level and a one-line summary.
   The next release folds it into `CHANGELOG.md`.

## Versioning & releases

The toolchain is versioned with [SemVer](https://semver.org); `VERSION` is the
single source of truth and `ludicc --version` (or `ludic version`) reports it.

Releases are changeset-driven. Every user-facing change ships with a changeset
(step 5 above). Read the next release before cutting it:

```bash
ludic-dev release --dry-run             # render the CHANGELOG section, write nothing
```

Then cut it:

```bash
ludic-dev release [major|minor|patch]   # omit the level to derive it from the changesets
git push origin main --follow-tags
```

`ludic-dev release` aggregates the pending changesets into a new `CHANGELOG.md` section
— grouped by change type, with each changeset's markdown kept intact — bumps
`VERSION`, commits `chore(release): vX.Y.Z`, and tags it.

**Pushing the tag is what publishes.** The `release` workflow builds the
toolchain from the IR seed, runs `ludic-dev test`, `ludic-dev test-tools` and `ludic-dev bootstrap-cfree`
against the tagged tree, and only then creates the Forgejo release — with the
source tarball, a Linux toolchain build, a `.sha256` beside each, and that version's
`CHANGELOG.md` section as the notes. It refuses to publish if the tag and
`VERSION` disagree or the changelog has no section for it.

Each toolchain artifact is a complete install root — `bin/` beside `runtime/`,
`packages/` and `VERSION` — which is exactly what `install.sh` unpacks into
`~/.ludic`. A release with no artifact for a platform is not a broken install
there: the installer falls back to bootstrapping from the source tarball's IR
seed. But the macOS artifacts are the ones most people get, so attach them.

macOS artifacts cannot be produced on the Linux runner — a `darwin-arm64` build
needs a macOS host, and there is no cross-compile path (it would need the Xcode
SDK and a Mach-O linker). Attaching one therefore means either registering a
macOS runner and giving it a job, or running the same command CI runs from a
Mac. Either way it is `ludic-dev publish`, which only adds assets the release is missing:

```bash
FORGEJO_TOKEN=… ludic-dev publish v0.4.0
```

Checksums are one `.sha256` file per artifact rather than a single `SHA256SUMS`,
precisely because a release can be assembled from more than one host and an
asset that already exists is never overwritten. Verify one with:

```bash
shasum -a 256 -c ludic-0.4.0-src.tar.gz.sha256
```

The tag doubles as the reproducible bootstrap point: the source archive plus its
checked-in seed rebuild that exact toolchain.

## Where the name and the URLs live

The language may yet be renamed and the project may yet move hosts, so the
things that carry a name are kept few and listed here rather than discovered one
broken link at a time. Everything host-shaped has an environment override, so a
move can be rehearsed before it is committed.

**Hosts and URLs.** The install one-liner is served from the documentation site,
which publishes `install.sh` beside the pages that quote it (`ludic-dev docs-gen`
copies it in; `docs-check` fails without it). Change the host in:

| Where | What |
|---|---|
| `install.sh` | `REPO_API`, `REPO_URL`, `INSTALL_URL` — each `${LUDIC_…:-default}`, so `LUDIC_REPO_URL=… sh install.sh` tests a move without editing anything |
| `tools/ludic-cli/project.ludic` | `install_url()` (`$LUDIC_INSTALL_URL`), used by `ludic upgrade` and `ludic doctor` |
| `tools/ludic-cli/forgejo.ludic` | `FORGEJO_API_DEFAULT` (`$LUDIC_FORGEJO_API`), used by `ludic-dev publish` |
| `docs/site/site.json` | `repo_url`, the `start.terminal` one-liner, and the doc links in `nav_links` |
| Prose | `README.md`, `COMPILING.md`, `tools/editors/README.md`, and the two editor plugins' "server not found" messages |

**The name itself.** A rename touches, in rough order of blast radius:

- **The file extension** `.ludic` — the compiler (`strip_ludic`, `do_import`,
  `is_ludic_file`), every editor asset (`tools/editors/shared/*.json`,
  `vscode/package.json`, the JetBrains `LudicFileType`), and every source file
  in the tree.
- **The binaries** `ludic`, `ludicc`, `ludic-dev`, `ludic-fmt`, `ludic-lsp` —
  `cmd_dev_build` in `toolchain.ludic`, the release staging in `release.ludic`,
  `install.sh`, the editors' executable-name lists. Only the first, third and
  fourth of those ship: `ludic-dev` is built from a checkout and stays there.
- **The install root** `~/.ludic` and the source directories `tools/ludic-cli/`,
  `tools/ludic-tools/`, `packages/ludic.*`.
- **The environment variables** `LUDIC_HOME`, `LUDIC_CC`, `LUDIC_MODULES`,
  `LUDIC_STORE`, `LUDIC_PKG_PROXY`, `LUDIC_INSTALL_URL`, `LUDIC_KEEP_TMP`,
  `LUDIC_COVERAGE` — keep the old names working for a release if anyone has them
  in a script.
- **Identifiers that are contracts with other software**: the TextMate scope
  `source.ludic`, the VS Code language id `ludic`, the JetBrains plugin id
  `io.ludic.ide`, and the `ludic` code-fence tag understood by the Markdown
  injection and by `ludic-dev check-docs`.
- **The prose**: `README.md`, `LANGUAGE.md`, `COMPILING.md`, `docs/**`, and
  `docs/site/site.json`'s `brand`/`meta`.

`ludic-dev test` is the safety net for the mechanical part — it builds the
toolchain, stages an install, and runs `new` → `build` → `test` through it, so a
half-finished rename fails there rather than in someone's terminal.

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
  | `build` | the build/bootstrap machinery (seed, `bin/ludic`, linking) |
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
  the repo `.editorconfig` mirrors it. Run `bin/ludic fmt` on files you touch.
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
- Ensure `bin/ludic-dev test` (and `bin/ludic-dev bootstrap-cfree` for compiler/runtime changes)
  pass, and that `ludic-fmt` leaves your files unchanged.
- Fill in the PR template checklist. Reference the issue you close with
  `Closes #NN` in the description or a commit message.

## CI (self-hosted runners)

Every workflow starts by cloning `${{ github.server_url }}/${{ github.repository }}`.
On a self-hosted Forgejo runner that URL is usually the instance's *internal*
address (e.g. `http://forgejo:3000`), so **the job container must be able to
resolve it**. The runner puts each job on a fresh per-job network by default,
which the Forgejo container is not attached to — so the clone fails with:

```
fatal: unable to access 'http://forgejo:3000/…': Could not resolve host: forgejo
```

Give the runner a config that pins job containers to a network Forgejo is also
on. A dedicated network is better than the general application network, so a CI
job cannot reach unrelated services:

```yaml
# the runner's config.yml, passed with: forgejo-runner daemon --config …
container:
  network: forgejo-ci
```

with `forgejo-ci` attached to the Forgejo container as well. Verify it without
running a workflow:

```bash
docker run --rm --network forgejo-ci alpine:3 getent hosts forgejo
```

This failure mode is intermittent if left unfixed: Docker forwards names it
cannot resolve to the host's resolver, which may answer for the container name
often enough that CI looks healthy for a while.

## Reporting issues

Use the templates under [`.forgejo/issue_template/`](.forgejo/issue_template):
a **bug report**, a **proposal** (new stdlib/language surface), or a
**cleanup/DX** task. Choose the one that fits and fill in the sections.

By participating you agree to the [Code of Conduct](CODE_OF_CONDUCT.md).
