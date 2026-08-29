---
id: vector-y
name: Vector.y
category: vector
kind: namespace-method
tokens: Vector.y
sig: Vector.y(v) -> fixed
tip: The y component of a vector.
order: 3
ns: Vector
member: y
---

Returns the <code>y</code> component of <code>v</code> as a <code>fixed</code>. The companion of <code>Vector.x</code>.

```ludic
program Demo {
  handler Step phase Update {
    let py = Vector.y(pos)
  }
}
```
