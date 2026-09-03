---
id: ivec2-within
name: IVec2.within
category: ivec2
kind: namespace-method
tokens: IVec2.within
sig: IVec2.within(a, b, radius) -> bool
tip: Are two points within a radius of each other?
order: 21
ns: IVec2
member: within
---

True when the distance between <code>a</code> and <code>b</code> is at most <code>radius</code> (compared squared, no square root).

```ludic
# doc-check: skip — illustrative
if IVec2.within(hero, heart, 14) { pick_up() }
```
