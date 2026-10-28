bump: patch
type: fix
**CI bootstraps the toolchain again.** The toolchain's own programs keep module-level vars, which a
plain compile now refuses; the bootstrap in `ci`, `bootstrap`, `docs` and `release`, `install.sh`'s
from-source install and `ludic`'s hint compile `tools/ludic-cli/dev.ludic` with `--unsafe --globals`,
as COMPILING.md already says.
