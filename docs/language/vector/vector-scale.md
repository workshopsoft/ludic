---
id: vector-scale
name: Vector.scale
category: vector
kind: namespace-method
tokens: Vector.scale
sig: Vector.scale(v, s) -> Vector
tip: Scale a vector by a scalar.
order: 6
ns: Vector
member: scale
---

Returns <code>v</code> scaled by the <code>fixed</code> factor <code>s</code>. Multiply a direction by a speed, or a velocity by delta-time.

```ludic
program Demo {
  handler Step phase Update {
    let step = Vector.scale(direction, speed)
  }
}
```
