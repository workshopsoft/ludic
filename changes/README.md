# Changesets

A **changeset** is one small Markdown file describing a single user-facing change,
dropped in this directory. `ludic dev release` consumes every changeset here into a new
`CHANGELOG.md` section, bumps `VERSION`, and deletes the consumed files.

## Format

```
bump: minor
type: feat
One or more lines describing the change, in the past-agnostic imperative used in
the changelog. Markdown is fine.
```

- `bump:` — `major`, `minor`, or `patch` (SemVer). The release version is bumped
  by the **highest** level among the pending changesets (unless `ludic dev release <level>`
  overrides it).
- `type:` — the Conventional Commit type (`feat`, `fix`, `perf`, `docs`, …). It
  decides which group the change lands in: `feat` → **Features**, `fix` →
  **Fixes**, `perf` → **Performance**, and so on, in that order. A type with no
  known heading gets one named after itself.

## Writing the body

The body is markdown and reaches the changelog as markdown: it becomes one list
item, with continuation lines indented to stay inside it. Nested bullets, blank
lines between paragraphs and inline code all survive.

```
bump: minor
type: feat
**Tiled map support** — load and draw Tiled maps.

- **TMX/TSX** — the XML formats, decoded to the same intermediate as JSON.
- **Collision** — the `collision` layer projects onto the engine tilemap.
```

Lead with the thing that changed, not with the mechanism. A reader scanning the
release should be able to stop after your first clause.

## Adding one

Create a file with a short, unique name, e.g. `changes/regex-namespace.md`. Any
filename works except this `README.md`, which the release step always skips.

Preview how the next release will read before cutting it — this writes nothing:

```bash
ludic dev release --dry-run
```
