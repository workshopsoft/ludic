---
id: ivec2-scale
name: IVec2.scale
category: ivec2
kind: namespace-method
tokens: IVec2.scale
sig: IVec2.scale(v, s) -> IVec2
tip: Multiply both components by an integer.
order: 6
ns: IVec2
member: scale
---

Multiplies both components by an integer scalar — useful to convert a cell coordinate into a pixel offset by the tile size.

```ludic
program Demo {
  handler Step phase Update {
    let px = IVec2.scale(cell, 16)
  }
}
```
