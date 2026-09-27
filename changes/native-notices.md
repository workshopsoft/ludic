bump: patch
type: feat
**A native library's licence ships with it.** `ludic bundle` copies each linked package's
`native/LICENSE*` files beside the `.exe` on Windows and into `Contents/Resources` on macOS, so
Jolt Physics' MIT notice travels with every copy of the game. `tools/native/lib.sh` passes lld-link
`-implib`, which Git Bash leaves alone (it rewrote `/implib:` into a Windows path).
