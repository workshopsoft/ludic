---
id: vector-lerp
name: Vector.lerp
category: vector
kind: namespace-method
tokens: Vector.lerp
sig: Vector.lerp(a, b, t) -> Vector
tip: Linear interpolation between two vectors.
order: 11
ns: Vector
member: lerp
---

Returns the component-wise linear interpolation between <code>a</code> and <code>b</code> by <code>t</code> (a <code>fixed</code> in 0.0..1.0). Great for smoothing a camera toward a target.

```ludic
program Demo {
  handler Step phase Update {
    camera = Vector.lerp(camera, target, 0.1)
  }
}
```
