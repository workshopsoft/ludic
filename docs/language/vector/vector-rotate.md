---
id: vector-rotate
name: Vector.rotate
category: vector
kind: namespace-method
tokens: Vector.rotate
sig: Vector.rotate(v, angle) -> Vector
tip: Rotate a vector by an angle in radians.
order: 12
ns: Vector
member: rotate
---

Returns <code>v</code> rotated counter-clockwise by <code>angle</code> radians, using the deterministic fixed-point sine table. Positive angles turn toward +y.

```ludic
program Demo {
  handler Step phase Update {
    let aimed = Vector.rotate(forward, spin)
  }
}
```
