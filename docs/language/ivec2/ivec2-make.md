---
id: ivec2-make
name: IVec2.make
category: ivec2
kind: namespace-method
tokens: IVec2.make
sig: IVec2.make(x, y) -> IVec2
tip: Build an integer vector from x and y components.
order: 0
ns: IVec2
member: make
---

Builds an <code>IVec2</code> from its integer <code>x</code> and <code>y</code> components. This is the usual way to name a tile or grid cell; read the parts back with <code>IVec2.x</code> and <code>IVec2.y</code>.

```ludic
program Demo {
  handler Step phase Update {
    let cell = IVec2.make(4, 7)
  }
}
```
