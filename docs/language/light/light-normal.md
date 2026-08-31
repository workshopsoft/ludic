---
id: light-normal
name: Light.normal
category: light
kind: namespace-method
tokens: Light.normal
sig: Light.normal(x, y, width, height, nx, ny)
tip: Stamp a surface normal over a rectangle so lights shade it by facing (N·L).
order: 10
ns: Light
member: normal
---

Stamps a **surface normal** over a screen rectangle into the light pass's normal buffer. Where a normal is stamped, a light shades the surface by the angle it faces — the Lambert term <code>N·L</code> — not by distance alone: a wall facing a torch is bright, one turned away is dim, giving flat sprites a sense of relief (tier 3). <code>nx</code> and <code>ny</code> are the normal's x/y as a <code>fixed</code> in <code>[-1, 1]</code> (a surface facing straight at the camera is <code>0, 0</code>); the z component is derived. Unstamped pixels are unaffected, and the buffer is allocated only when you stamp — clear it each frame with <a href="light-clear_normals"><code>Light.clear_normals</code></a>. Deterministic (Q16.16 dot product).

Parameters:
- `x`, `y`, `width`, `height` — the screen rectangle to stamp
- `nx`, `ny` — the surface normal's x/y, a `fixed` in `[-1, 1]`

```ludic
program Demo {
  property Wall { x: int = 0, y: int = 0 }
  model Block { Wall }
  handler Render phase Update {
    Screen.clear(0)
    Light.ambient(Color.rgb(24, 24, 32))
    Light.clear_normals()
    Light.normal(60, 50, 16, 24, 0.7, 0.0)                 # this face is tilted rightward
    Light.point(120, 62, 90, Color.rgb(255, 240, 200), 1.0)
    Screen.show()
  }
}
```
