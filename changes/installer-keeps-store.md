bump: patch
type: fix
An upgrade keeps the package store. The installer replaces the whole install
root, and `ludic add` caches packages in `~/.ludic/store` — so re-running the
one-liner deleted every package a project had fetched. The store is carried
across now; everything else in the root belongs to the toolchain and is replaced.
