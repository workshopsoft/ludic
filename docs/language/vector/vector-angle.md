---
id: vector-angle
name: Vector.angle
category: vector
kind: namespace-method
tokens: Vector.angle
sig: Vector.angle(v) -> fixed
tip: The angle of a vector in radians.
order: 13
ns: Vector
member: angle
---

Returns the angle of <code>v</code> in radians, measured from +x, in the range -pi..pi (via <code>atan2</code>). Feed it back into <code>Vector.from_angle</code> or <code>Vector.rotate</code>.

```ludic
program Demo {
  handler Step phase Update {
    let heading = Vector.angle(velocity)
  }
}
```
