bump: minor
type: feat
**`App.set_icon(path)`** — an icon for a binary that has no bundle to take one from.

`ludic bundle` builds an `AppIcon.icns` and macOS reads it from the `.app`, so a
shipped game has an icon. `ludic build` produces a bare executable, which has no
bundle, no `CFBundleIconFile` and therefore no icon at all — macOS draws the generic
green "exec" tile in the Dock. That is the build a developer runs all day and the one
they see every session, so "my game has no icon" is true long before it ships.

```ludic
App.set_icon("assets/app/icon.png")
```

The path resolves through the pack first and the filesystem second, like every other
asset, so the same call works packed and unpacked — it does not repeat `Audio.load`'s
trick of taking a filesystem path only. An image that cannot be found or decoded
leaves the current icon alone rather than clearing it, calling it in a bundled app is
a harmless no-op, and a headless build compiles it away to nothing.
