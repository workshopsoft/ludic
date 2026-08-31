---
id: light-gel
name: Light.gel
category: light
kind: namespace-method
tokens: Light.gel
sig: Light.gel(color)
tip: A colour cookie — later lights gel from their centre colour to this rim colour.
order: 8
ns: Light
member: gel
---

Sets a **gel** (a colour cookie) for lights emitted after it: the light blends from its own <code>color</code> at the centre to this <code>color</code> at the rim, so a single light can carry a two-tone tint — a warm core cooling to a blue edge, a fire that reddens outward. Clear it with <a href="light-clear_gel"><code>Light.clear_gel</code></a> to return to a flat single-colour light. The gel rides on both <a href="light-point"><code>Light.point</code></a> and <a href="light-spot"><code>Light.spot</code></a>, and persists until cleared. Per-channel Q16.16 interpolation — deterministic.

Parameters:
- `color` — the rim colour, `0x00RRGGBB`

```ludic
program Demo {
  property Torch { x: int = 0, y: int = 0 }
  model Lamp { Torch }
  handler Render phase Update {
    Screen.clear(0)
    Light.ambient(Color.rgb(24, 24, 32))
    Light.gel(Color.rgb(40, 60, 160))                      # cool blue rim
    Light.point(80, 60, 70, Color.rgb(255, 200, 120), 1.0) # warm core
    Light.clear_gel()
    Screen.show()
  }
}
```
