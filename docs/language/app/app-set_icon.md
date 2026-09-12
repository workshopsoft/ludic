---
id: app-set_icon
name: App.set_icon
category: app
kind: namespace-method
tokens: App.set_icon
sig: App.set_icon(path) -> void
tip: Set the Dock icon from an image the game ships.
order: 2
ns: App
member: set_icon
---

Sets the application's icon — the Dock tile, the Cmd-Tab switcher, the About box — from an image the game ships.

A **bundled** app already has one: `ludic bundle` builds `AppIcon.icns` from the manifest's `app icon` and macOS reads it from the bundle, so calling this there is harmless and changes nothing you can see. A **plain binary** is the case this exists for. `ludic build` produces an executable with no bundle around it, so macOS has nowhere to find an icon and draws the generic one — which is what a developer looks at every time they run the game.

The path is resolved the same way every other asset is, through the pack first and the filesystem second, so the same call works in a packed build and in a project directory. An image that cannot be found or decoded leaves the current icon alone rather than clearing it.

Parameters:
- `path` — an image the game ships (PNG, JPEG or TIFF); 1024x1024 is the size macOS wants

```ludic
program Titled {
  entry {
    App.set_icon("assets/app/icon.png")
  }
}
```

Headless builds have no AppKit, so this compiles to nothing there.
