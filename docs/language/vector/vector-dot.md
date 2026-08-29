---
id: vector-dot
name: Vector.dot
category: vector
kind: namespace-method
tokens: Vector.dot
sig: Vector.dot(a, b) -> fixed
tip: The dot product of two vectors.
order: 7
ns: Vector
member: dot
---

Returns the dot product <code>ax*bx + ay*by</code> as a <code>fixed</code>. Zero when the vectors are perpendicular; use it to project one vector onto another or to test facing.

```ludic
program Demo {
  handler Step phase Update {
    let facing = Vector.dot(forward, toTarget)
  }
}
```
