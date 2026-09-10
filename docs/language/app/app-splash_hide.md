---
id: app-splash_hide
name: App.splash_hide
category: app
kind: namespace-method
tokens: App.splash_hide
sig: App.splash_hide() -> void
tip: Dismiss the boot splash.
order: 1
ns: App
member: splash_hide
---

Dismisses the boot splash. Safe to call when there is no splash, and safe to call twice.

A bundled game shows a splash while it starts: `ludic bundle` records `app splash` from the manifest into the bundle, and the runtime puts it on screen before `main` runs, out of the asset pack. Nothing takes it down on its own, because nothing else knows when the game has a first frame worth showing - a splash that disappears while the terrain is still loading leaves the same black gap it was there to cover.

So the game says when:

```ludic skip
program MyGame {
  entry {
    load_the_world()          # the slow part the splash is covering
    open_the_window()
    draw_one_frame()
    App.splash_hide()         # ...and only now
  }
}
```

Headless there is no splash and no window, and the call lowers to nothing.

See also: <a href="../../SHIPPING">shipping a game</a>.
