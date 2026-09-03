---
id: ivec2-distance2
name: IVec2.distance2
category: ivec2
kind: namespace-method
tokens: IVec2.distance2
sig: IVec2.distance2(a, b) -> int
tip: The squared distance between two points.
order: 20
ns: IVec2
member: distance2
---

<code>dx*dx + dy*dy</code> — compare it against a squared radius to avoid a square root.

```ludic
# doc-check: skip — illustrative
if IVec2.distance2(hero, foe) < 24 * 24 { … }
```
