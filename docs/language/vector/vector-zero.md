---
id: vector-zero
name: Vector.zero
category: vector
kind: namespace-method
tokens: Vector.zero
sig: Vector.zero() -> Vector
tip: The zero vector, (0, 0).
order: 1
ns: Vector
member: zero
---

Returns the zero vector <code>(0, 0)</code> — a convenient identity for accumulating a sum of vectors or clearing a velocity.

```ludic
program Demo {
  handler Step phase Update {
    var velocity = Vector.zero()
  }
}
```
