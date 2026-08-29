---
id: vector-x
name: Vector.x
category: vector
kind: namespace-method
tokens: Vector.x
sig: Vector.x(v) -> fixed
tip: The x component of a vector.
order: 2
ns: Vector
member: x
---

Returns the <code>x</code> component of <code>v</code> as a <code>fixed</code>. The companion of <code>Vector.y</code>.

```ludic
program Demo {
  handler Step phase Update {
    let px = Vector.x(pos)
  }
}
```
