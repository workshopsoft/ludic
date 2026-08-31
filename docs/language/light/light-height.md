---
id: light-height
name: Light.height
category: light
kind: namespace-method
tokens: Light.height
sig: Light.height(height)
tip: Set the virtual height of lights above the surface, for normal-map shading.
order: 12
ns: Light
member: height
---

Sets how far above the surface plane lights sit, in pixels — the <code>z</code> distance used when shading <a href="light-normal"><code>normal-mapped</code></a> surfaces. A low height makes light rays graze the surface, so tilted faces contrast sharply; a high height lights everything more head-on. It only affects the <code>N·L</code> term, so a scene with no stamped normals is unchanged. The default (<code>64</code>) suits most scenes. Persists until changed.

Parameters:
- `height` — the light's height above the plane in pixels (`> 0`)

```ludic
program Demo {
  property Wall { x: int = 0, y: int = 0 }
  model Block { Wall }
  handler Render phase Update {
    Screen.clear(0)
    Light.clear_normals()
    Light.height(24)                                       # low, grazing light
    Light.normal(60, 50, 16, 24, 0.7, 0.0)
    Light.point(120, 62, 90, Color.rgb(255, 240, 200), 1.0)
    Screen.show()
  }
}
```
