---
id: ivec2-zero
name: IVec2.zero
category: ivec2
kind: namespace-method
tokens: IVec2.zero
sig: IVec2.zero() -> IVec2
tip: The origin cell, (0, 0).
order: 1
ns: IVec2
member: zero
---

Returns the origin <code>(0, 0)</code> — a handy neutral value to start an accumulation or mark an unset cell.

```ludic
program Demo {
  handler Step phase Update {
    let origin = IVec2.zero()
  }
}
```
