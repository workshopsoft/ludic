---
id: light-point
name: Light.point
category: light
kind: namespace-method
tokens: Light.point
sig: Light.point(x, y, radius, color, energy)
tip: Add a radial glow that falls off with distance.
order: 2
ns: Light
member: point
---

Additively accumulates a radial point light centred at <code>(x, y)</code>. Brightness is full at the centre and falls off linearly to zero at <code>radius</code> pixels, scaled by <code>energy</code> (a <code>fixed</code> multiplier — <code>1.0</code> is full, <code>2.0</code> over-drives toward white, <code>0.5</code> is dim), and clamped per channel at 255 so overlapping lights add without wrapping. Only the light's bounding box is touched, and any <a href="light-occlude"><code>Light.occlude</code></a> rectangle between the centre and a pixel puts that pixel in shadow. Colours are <code>0x00RRGGBB</code>.

Parameters:
- `x`, `y` — the light centre, in screen pixels
- `radius` — the reach in pixels; brightness is zero at and beyond it
- `color` — the light colour, `0x00RRGGBB`
- `energy` — a `fixed` brightness multiplier (`1.0` = full)

```ludic
program Demo {
  property Torch { x: int = 0, y: int = 0 }
  model Lamp { Torch }
  handler Render phase Update {
    Screen.clear(0)
    Light.ambient(Color.rgb(32, 32, 48))
    Light.point(80, 60, 70, Color.rgb(255, 210, 130), 1.0)   # a warm torch
    Screen.show()
  }
}
```
