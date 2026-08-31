---
id: tween-value
name: Tween.value
category: tween
kind: namespace-method
tokens: Tween.value
sig: Tween.value(handle) -> int
tip: The current value of a fluent tween handle this frame.
order: 33
ns: Tween
member: value
---

Returns the current interpolated value of a <a href="tween-to"><code>tween handle</code></a> this frame — the number the engine advanced it to. Read it each frame to drive a position, an alpha, a scale. Once every segment has finished the value rests on the final target; <a href="tween-done"><code>Tween.done</code></a> reports when that has happened. Returns <code>0</code> for an invalid handle.

Parameters:
- `handle` — the tween handle to read

```ludic
program Demo {
  property Pos { x: int = 0 }
  property Tw { h: int = 0 }
  model Mover { Pos, Tw }
  handler Move phase Update {
    let p = World.prop_id("Pos")
    let t = World.prop_id("Tw")
    let e = World.query_next(t, 0)
    let h = World.get(e, t, World.field_id(t, "h"))
    World.set(e, p, World.field_id(p, "x"), Tween.value(h))
  }
}
```
