---
id: ivec2-equal
name: IVec2.equal
category: ivec2
kind: namespace-method
tokens: IVec2.equal
sig: IVec2.equal(a, b) -> bool
tip: True when both components match.
order: 8
ns: IVec2
member: equal
---

Compares two integer vectors for exact equality — true only when both the <code>x</code> and <code>y</code> components match.

```ludic
program Demo {
  handler Step phase Update {
    if IVec2.equal(pos, goal) { win() }
  }
}
```
