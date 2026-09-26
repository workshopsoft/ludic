bump: minor
type: feat
**A package can carry a native library.** `native "<target>" "<path>"` in a package's
`package.ludic` names a C/C++ library per target (`macos-arm64`, `windows-x64`, ...). The
compiler records the libraries of every package a program imports, and every link - `ludicc -o`,
`ludic build`, `ludic test`, `ludic bundle` - links them: on macOS with an rpath to the package
and to `Contents/Frameworks`, where `ludic bundle` places and signs them; on Windows through the
import library, the `.dll` copied beside the executable. `tools/native/lib.sh` builds a library
from a pinned, checksummed source; `ludic.nativeecho` is the worked example, and
`packages/README.md` says what a shim may pass across.
