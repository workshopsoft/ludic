---
id: light-clear_gel
name: Light.clear_gel
category: light
kind: namespace-method
tokens: Light.clear_gel
sig: Light.clear_gel()
tip: Clear the gel — later lights are a flat single colour again.
order: 9
ns: Light
member: clear_gel
---

Clears any <a href="light-gel"><code>Light.gel</code></a> set earlier, so lights emitted after it are a flat single colour again (no centre-to-rim tint). Pair it with <code>Light.gel</code> to scope a colour cookie to just one light.

```ludic
program Demo {
  property Torch { x: int = 0, y: int = 0 }
  model Lamp { Torch }
  handler Render phase Update {
    Screen.clear(0)
    Light.ambient(Color.rgb(24, 24, 32))
    Light.gel(Color.rgb(40, 60, 160))
    Light.point(60, 60, 60, Color.rgb(255, 200, 120), 1.0)  # gelled
    Light.clear_gel()
    Light.point(150, 60, 60, Color.rgb(255, 240, 200), 1.0)  # flat again
    Screen.show()
  }
}
```
