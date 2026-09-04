bump: minor
type: fix
`x release` keeps a changeset's markdown intact. Bodies used to go through
`tr '\n' ' '`, which flattened every multi-line changeset into one paragraph —
nested bullets came out as inline `" - "` runs and a release read as a single
unbroken wall of text. A section is now grouped by change type (**Features**,
**Fixes**, **Performance**, …) with one bullet per changeset and continuation
lines indented to stay inside it.

- `x release --dry-run` renders the next section to stdout and writes nothing,
  so a release can be read before it is cut.
- `x changelog-section <version>` prints one release's section from
  `CHANGELOG.md`; `x changelog-render` re-renders a section from a directory of
  changesets. The v0.1.0 and v0.3.0 sections were re-rendered with these.
