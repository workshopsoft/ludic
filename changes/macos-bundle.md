bump: minor
type: feat
**`ludic bundle`** turns a built game into a real macOS `.app`: `Info.plist` and
`PkgInfo` from the manifest, an `.icns` built from one source PNG at every size
macOS asks for, the asset pack in `Contents/Resources`, and an ad-hoc signature
so it launches on Apple silicon. Everything comes from `app` lines in
`package.ludic`, so the command takes no arguments. A bundled game is also moved
to `~/Library/Application Support/<name>` at startup, because Finder starts a
`.app` with its working directory at `/` where no save could ever be written.
