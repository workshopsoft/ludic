---
id: light-ambient
name: Light.ambient
category: light
kind: namespace-method
tokens: Light.ambient
sig: Light.ambient(color)
tip: Multiply the whole scene by a tint — the night/cave modulate.
order: 1
ns: Light
member: ambient
---

Multiplies every framebuffer pixel by <code>color</code> (a <code>0x00RRGGBB</code> tint), channel by channel (<code>channel * tint / 255</code>). This is the global modulate that sets mood before any light adds brightness back: a dim blue-grey gives night, a warm brown gives a cave, and <code>0xFFFFFF</code> is a no-op. Call it once, after drawing the scene and before the <a href="light-point"><code>Light.point</code></a> calls that light it back up.

Parameters:
- `color` — the ambient tint, `0x00RRGGBB` (darker/cooler = a darker scene)

```ludic
program Demo {
  property Tag { v: int = 0 }
  model Marker { Tag }
  handler Render phase Update {
    Screen.clear(Color.rgb(120, 120, 140))
    Light.ambient(Color.rgb(48, 48, 72))   # dusk: dim and cool
    Light.point(160, 120, 90, Color.Amber, 1.0)
    Screen.show()
  }
}
```
