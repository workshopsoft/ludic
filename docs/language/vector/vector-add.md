---
id: vector-add
name: Vector.add
category: vector
kind: namespace-method
tokens: Vector.add
sig: Vector.add(a, b) -> Vector
tip: Component-wise sum a + b.
order: 4
ns: Vector
member: add
---

Returns the component-wise sum <code>a + b</code> — the workhorse for stepping a position by a velocity each frame.

```ludic
program Demo {
  handler Step phase Update {
    pos = Vector.add(pos, velocity)
  }
}
```
