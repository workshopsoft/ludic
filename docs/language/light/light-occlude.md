---
id: light-occlude
name: Light.occlude
category: light
kind: namespace-method
tokens: Light.occlude
sig: Light.occlude(x, y, width, height)
tip: Register a rectangle that blocks light — a hard shadow caster.
order: 3
ns: Light
member: occlude
---

Registers an axis-aligned rectangle (screen space) that blocks light: for every <a href="light-point"><code>Light.point</code></a> that follows, any pixel whose ray from the light centre crosses this rectangle — or lies inside it — is left in shadow, carving a hard umbra behind the wall. Register the geometry that should cast shadows this frame, then draw the lights. Occluders persist until <a href="light-clear_occluders"><code>Light.clear_occluders</code></a>, so call that once per frame first; up to 64 occluders are kept.

Parameters:
- `x`, `y` — the top-left corner, in screen pixels
- `width`, `height` — the rectangle size in pixels

```ludic
program Demo {
  property Wall { x: int = 0, y: int = 0 }
  model Block { Wall }
  handler Render phase Update {
    Screen.clear(0)
    Light.clear_occluders()
    Light.occlude(120, 80, 8, 48)                 # a pillar
    Light.point(60, 100, 120, Color.rgb(255, 240, 200), 1.0)
    Screen.show()
  }
}
```
