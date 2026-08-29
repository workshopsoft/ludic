---
id: vector-normalize
name: Vector.normalize
category: vector
kind: namespace-method
tokens: Vector.normalize
sig: Vector.normalize(v) -> Vector
tip: A unit vector in the same direction.
order: 10
ns: Vector
member: normalize
---

Returns a unit-length vector pointing the same way as <code>v</code>. The zero vector maps to itself, so this never divides by zero. Scale the result by a speed to build a velocity.

```ludic
program Demo {
  handler Step phase Update {
    let dir = Vector.normalize(Vector.sub(target, pos))
  }
}
```
