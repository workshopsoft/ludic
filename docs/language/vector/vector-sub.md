---
id: vector-sub
name: Vector.sub
category: vector
kind: namespace-method
tokens: Vector.sub
sig: Vector.sub(a, b) -> Vector
tip: Component-wise difference a - b.
order: 5
ns: Vector
member: sub
---

Returns the component-wise difference <code>a - b</code> — the vector that points from <code>b</code> to <code>a</code>. Pair it with <code>Vector.length</code> or <code>Vector.normalize</code> to get a distance or a direction.

```ludic
program Demo {
  handler Step phase Update {
    let toTarget = Vector.sub(target, pos)
  }
}
```
