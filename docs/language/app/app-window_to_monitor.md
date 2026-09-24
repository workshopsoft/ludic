---
id: app-window_to_monitor
name: App.window_to_monitor
category: app
kind: namespace-method
tokens: App.window_to_monitor
sig: App.window_to_monitor(index)
tip: Moves the window to that display.
order: 50
ns: App
member: window_to_monitor
---

Moves the game's window onto display `index` (0 is the main one), keeping its size. A no-op where the platform leaves moving windows between screens to the player.

Parameters:
- `index` — which display, 0 to `App.monitor_count() - 1`

```ludic
program Move {
  entry { App.window_to_monitor(0) }
}
```
