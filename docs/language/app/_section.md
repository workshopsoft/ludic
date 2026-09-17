---
id: app
title: App
order: 48
---

The running application, as distinct from its window. Today that is the boot splash: the runtime raises it before <code>main</code> from the game's asset pack, and <a href="app-splash_hide"><code>App.splash_hide</code></a> takes it down when the game has something to show instead. <a href="app-window_hide"><code>App.window_hide</code></a> and <a href="app-window_show"><code>App.window_show</code></a> take the game's own window off the screen and bring it back without closing it — a launcher stepping aside while the game it started runs.
