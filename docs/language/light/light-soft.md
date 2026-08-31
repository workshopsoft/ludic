---
id: light-soft
name: Light.soft
category: light
kind: namespace-method
tokens: Light.soft
sig: Light.soft(radius)
tip: Soft shadows — an occluder edge fades through a penumbra of this radius.
order: 7
ns: Light
member: soft
---

Turns on **soft shadows** for lights emitted after it. A hard shadow tests a single ray from the light centre to each pixel, so an <a href="light-occlude"><code>occluder</code></a> edge cuts sharply. With <code>radius > 0</code> the light is treated as a small disk of that radius: each pixel samples visibility from a cross of points across the disk and averages them, so the shadow edge fades through a **penumbra** instead of a hard line. <code>Light.soft(0)</code> restores hard, single-sample shadows. The setting persists until changed. Deterministic (fixed-point average of integer ray tests).

Parameters:
- `radius` — the light's apparent size in pixels; larger = wider penumbra (`0` = hard)

```ludic
program Demo {
  property Torch { x: int = 0, y: int = 0 }
  model Lamp { Torch }
  handler Render phase Update {
    Screen.clear(0)
    Light.ambient(Color.rgb(24, 24, 32))
    Light.clear_occluders()
    Light.occlude(96, 40, 6, 40)                           # a pillar casting a shadow
    Light.soft(5)                                          # 5px penumbra
    Light.point(60, 60, 90, Color.rgb(255, 240, 200), 1.0)
    Screen.show()
  }
}
```
