bump: patch
type: fix
Release checksums are one `.sha256` file per artifact instead of a single
`SHA256SUMS`. A release is assembled from more than one host — a Linux runner
cannot build the macOS toolchain — and `ludic dev publish` never overwrites an asset that
is already attached, so a shared `SHA256SUMS` was written by whichever host
published first and then never covered anything added afterwards. Per-artifact
names compose across hosts. Verify one with
`shasum -a 256 -c ludic-X.Y.Z-src.tar.gz.sha256`.
