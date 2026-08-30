# Changesets

A **changeset** is one small Markdown file describing a single user-facing change,
dropped in this directory. `x release` consumes every changeset here into a new
`CHANGELOG.md` section, bumps `VERSION`, and deletes the consumed files.

## Format

```
bump: minor
type: feat
One or more lines describing the change, in the past-agnostic imperative used in
the changelog. Markdown is fine.
```

- `bump:` — `major`, `minor`, or `patch` (SemVer). The release version is bumped
  by the **highest** level among the pending changesets (unless `x release <level>`
  overrides it).
- `type:` — the Conventional Commit type (`feat`, `fix`, `perf`, `docs`, …); it
  becomes the bold prefix of the changelog bullet.

## Adding one

Create a file with a short, unique name, e.g. `changes/regex-namespace.md`. Any
filename works except this `README.md`, which the release step always skips.
