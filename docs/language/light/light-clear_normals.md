---
id: light-clear_normals
name: Light.clear_normals
category: light
kind: namespace-method
tokens: Light.clear_normals
sig: Light.clear_normals()
tip: Forget every stamped normal — call once per frame before re-stamping.
order: 11
ns: Light
member: clear_normals
---

Clears the normal buffer set by <a href="light-normal"><code>Light.normal</code></a>, so every pixel is flat again (lit by distance only). Call it once per frame before re-stamping the surfaces that should shade by facing this frame — the same clear-then-register rhythm as <a href="light-clear_occluders"><code>Light.clear_occluders</code></a>. A no-op if no normal was ever stamped.

```ludic
program Demo {
  property Wall { x: int = 0, y: int = 0 }
  model Block { Wall }
  handler Render phase Update {
    Screen.clear(0)
    Light.clear_normals()
    Light.normal(60, 50, 16, 24, 0.7, 0.0)
    Light.point(120, 62, 90, Color.rgb(255, 240, 200), 1.0)
    Screen.show()
  }
}
```
