bump: minor
type: ci
Releases are published by CI from a tag instead of by hand from a laptop. The
new `release` workflow triggers on a `v*` tag, builds the toolchain from the IR
seed, runs `x test`, `x test-tools` and `x bootstrap-cfree` against the tagged
tree, and only then creates the Forgejo release. It refuses to publish when the
tag and `VERSION` disagree or `CHANGELOG.md` has no section for that version.

`x publish [vX.Y.Z]` is the command behind it and works locally too: it builds
`dist/` (a source tarball from the tag, this host's toolchain, and a
`SHA256SUMS` covering both — releases previously shipped no checksums) and takes
the release notes from that version's `CHANGELOG.md` section, so the notes and
the changelog cannot drift. Re-running it only adds assets the release is
missing, which is how a macOS build gets attached to a Linux-built release.
