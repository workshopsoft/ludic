---
id: app-window_show
name: App.window_show
category: app
kind: namespace-method
tokens: App.window_show
sig: App.window_show() -> void
tip: Bring the game's window back.
order: 4
ns: App
member: window_show
---

Puts a window hidden by <a href="app-window_hide.html"><code>App.window_hide</code></a> back on screen, in front and focused, as it was. Safe to call on a window that is already showing, when there is no window, and headless, where it lowers to nothing.

```ludic skip
program Demo {
  entry {
    App.window_hide()
    wait_for_the_game()
    App.window_show()
  }
}
```

On macOS <code>makeKeyAndOrderFront:</code> and the application is activated. On Windows <code>ShowWindow(SW_SHOW)</code> and <code>SetForegroundWindow</code>; Windows may refuse the focus to a program that is not in the foreground, in which case the window comes back and its taskbar button flashes instead.
