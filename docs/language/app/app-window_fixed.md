---
id: app-window_fixed
name: App.window_fixed
category: app
kind: namespace-method
tokens: App.window_fixed
sig: App.window_fixed(fixed)
tip: A window that cannot be resized or maximised.
order: 51
ns: App
member: window_fixed
---

With `true`, the window has no resize grip and no maximise button - for a launcher or a dialog, which a player should not take for the game itself.

Parameters:
- `fixed` — `true` to fix the window's size, `false` to free it

```ludic
program Launcher {
  entry { App.window_fixed(true) }
}
```
