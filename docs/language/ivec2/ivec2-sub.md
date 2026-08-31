---
id: ivec2-sub
name: IVec2.sub
category: ivec2
kind: namespace-method
tokens: IVec2.sub
sig: IVec2.sub(a, b) -> IVec2
tip: Component-wise difference of two integer vectors.
order: 5
ns: IVec2
member: sub
---

Subtracts <code>b</code> from <code>a</code> component-wise, giving the integer offset from one cell to another.

```ludic
program Demo {
  handler Step phase Update {
    let delta = IVec2.sub(target, pos)
  }
}
```
