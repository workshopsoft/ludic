---
id: ivec2-add
name: IVec2.add
category: ivec2
kind: namespace-method
tokens: IVec2.add
sig: IVec2.add(a, b) -> IVec2
tip: Component-wise sum of two integer vectors.
order: 4
ns: IVec2
member: add
---

Adds two integer vectors component-wise. Adding a direction step to a position is how a token moves one cell on a grid.

```ludic
program Demo {
  handler Step phase Update {
    let next = IVec2.add(pos, IVec2.make(1, 0))
  }
}
```
