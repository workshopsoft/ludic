---
id: tiled-draw_anim
name: Tiled.draw_anim
category: tiled
kind: namespace-method
tokens: Tiled.draw_anim
sig: Tiled.draw_anim(map, camx: int, camy: int, frame: int) -> void
tip: Draw with animated tiles advanced to a frame.
order: 17
ns: Tiled
member: draw_anim
---

Like <a href="tiled-draw"><code>Tiled.draw</code></a>, but animated tiles are advanced to the engine <code>frame</code> (pass <a href="time-frame"><code>Time.frame</code></a>) and every tile object on the object layers is drawn too. The animation frame is a pure function of the fixed 60/s clock, so it reproduces frame-for-frame across runs and lockstep replays.
