---
id: vector-from_angle
name: Vector.from_angle
category: vector
kind: namespace-method
tokens: Vector.from_angle
sig: Vector.from_angle(a) -> Vector
tip: A unit vector pointing at an angle.
order: 14
ns: Vector
member: from_angle
---

Returns the unit vector <code>(cos a, sin a)</code> pointing at <code>a</code> radians. Scale it by a speed to launch a projectile in a chosen direction.

```ludic
program Demo {
  handler Step phase Update {
    let shot = Vector.scale(Vector.from_angle(aim), 200.0)
  }
}
```
