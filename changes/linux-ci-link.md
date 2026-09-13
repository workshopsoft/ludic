bump: patch
type: fix
**The toolchain links on Linux again** — CI builds, tests and publishes releases.

The asset-pack boot finds the directory beside the executable with `_NSGetExecutablePath`,
which Darwin's libc has and glibc does not, so every Linux link of the compiler seed failed
from the release that added packs onward: CI's build, suite and C-free bootstrap jobs, and
every `publish` run, so no release after v0.7.0 carried a Linux toolchain or was created by
CI at all. `tools/ci/linux_stdio_shim.ll` now supplies it, over `/proc/self/exe`.
