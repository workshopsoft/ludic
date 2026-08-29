---
id: vector-make
name: Vector.make
category: vector
kind: namespace-method
tokens: Vector.make
sig: Vector.make(x, y) -> Vector
tip: Build a vector from x and y components.
order: 0
ns: Vector
member: make
---

Builds a <code>Vector</code> from its <code>x</code> and <code>y</code> components (both <code>fixed</code>). This is the usual way to make a position or a velocity; read the parts back with <code>Vector.x</code> and <code>Vector.y</code>.

```ludic
program Demo {
  handler Step phase Update {
    let pos = Vector.make(64.0, 32.0)
  }
}
```
