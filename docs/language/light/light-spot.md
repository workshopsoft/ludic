---
id: light-spot
name: Light.spot
category: light
kind: namespace-method
tokens: Light.spot
sig: Light.spot(x, y, radius, color, energy, direction, spread)
tip: A cone / flashlight light aimed at a direction with a half-angle spread.
order: 5
ns: Light
member: spot
---

Accumulates a **cone** (spot) light — like <a href="light-point"><code>Light.point</code></a>, but only the wedge aimed at <code>direction</code> degrees (measured from <code>+x</code>, counter-clockwise) within a half-angle of <code>spread</code> degrees receives light. Pixels outside the cone stay dark, and the last few degrees of the edge feather so the boundary is not a hard line. A spot shares every quality control with a radial light — <a href="light-falloff"><code>Light.falloff</code></a>, <a href="light-soft"><code>Light.soft</code></a>, <a href="light-gel"><code>Light.gel</code></a> and the <a href="light-normal"><code>normal buffer</code></a> all apply. Fully deterministic (integer degrees + Q16.16).

Parameters:
- `x`, `y` — the light centre, in screen pixels
- `radius` — the reach in pixels; brightness is zero at and beyond it
- `color` — the light colour, `0x00RRGGBB`
- `energy` — a `fixed` brightness multiplier (`1.0` = full)
- `direction` — the aim, in whole degrees (`0` = right, `90` = up, `180` = left)
- `spread` — the cone half-angle, in whole degrees (`180` ≈ omnidirectional)

```ludic
program Demo {
  property Torch { x: int = 0, y: int = 0 }
  model Lamp { Torch }
  handler Render phase Update {
    Screen.clear(0)
    Light.ambient(Color.rgb(24, 24, 32))
    Light.spot(80, 60, 70, Color.rgb(255, 240, 200), 1.0, 0, 30)   # a flashlight pointing right
    Screen.show()
  }
}
```
