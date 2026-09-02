---
id: camera-zoom
name: Camera.zoom
category: camera
kind: namespace-method
tokens: Camera.zoom
sig: Camera.zoom(scale)
tip: Scale the whole view about the screen centre by a Q16.16 factor (1.0 = none).
order: 4
ns: Camera
member: zoom
---

Sets a render-time zoom: every draw is scaled about the screen centre by <code>scale</code>, a Q16.16 <code>fixed</code> factor. <code>1.0</code> is no zoom (and turns the zoom path back off, restoring the byte-identical un-zoomed blit); <code>2.0</code> is 2x in; <code>0.5</code> is 2x out. It composes with <a href="camera-set"><code>Camera.set</code></a> / <a href="camera-follow"><code>Camera.follow</code></a> (which move the view) and <a href="camera-shake"><code>Camera.shake</code></a>.

Zoom is a *render-time transform*, not a change to the world coordinate types — those stay integer pixels + Q16.16 velocity so lockstep, replay and <code>world_save</code> hold (see the position-types RFC, #78). Because it rides on fixed-point, the zoom is itself deterministic: the same <code>scale</code> produces the same pixels on every machine and headless.

Parameters:
- `scale` — the zoom factor (`fixed`); `1.0` = no zoom, `>1` zooms in, `<1` zooms out

```ludic
program Demo {
  property Cam { z: fixed = 1.0 }
  model View { Cam }
  handler DrawWorld phase Render {
    Camera.zoom(2.0)
    Screen.fill_rectangle(150, 110, 20, 20, 0xffcc00)
    Screen.show()
  }
}
```
