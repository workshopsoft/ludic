---
id: app-window_hide
name: App.window_hide
category: app
kind: namespace-method
tokens: App.window_hide
sig: App.window_hide() -> void
tip: Take the game's window off the screen.
order: 3
ns: App
member: window_hide
---

Takes the game's window off the screen without closing it: its GL context or Vulkan surface, its size and its contents are kept, and the program goes on running — a hidden window does not end the run. <a href="app-window_show.html"><code>App.window_show</code></a> brings it back. It is how a launcher steps aside while the game it started with <a href="../process/process-spawn.html"><code>Process.spawn</code></a> runs.

Keep the frame loop going while hidden so the child can be polled, but there is nothing to see: skip the drawing, and throttle the loop yourself — a hidden window is not paced by the display, so an unthrottled loop spins. It does not touch the boot splash (<a href="app-splash_hide.html"><code>App.splash_hide</code></a> does). Safe to call when there is no window yet, and twice. Headless there is no window and the call lowers to nothing.

```ludic skip
program Launcher {
  var game: int = -1
  function play() -> void {
    game = Process.spawn(game_path(), new []string)
    if game >= 0 { App.window_hide() }
  }
  handler Watch phase Update {
    if game >= 0 and Process.poll(game) != -1 {
      Process.free(game)
      game = -1
      App.window_show()
    }
  }
}
```

<code>orderOut:</code> on macOS; <code>ShowWindow(SW_HIDE)</code> on Windows, which also forgets any key held as the window went.
