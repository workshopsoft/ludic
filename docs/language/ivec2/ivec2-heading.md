---
id: ivec2-heading
name: IVec2.heading
category: ivec2
kind: namespace-method
tokens: IVec2.heading
sig: IVec2.heading(from, to) -> int
tip: The direction from one point to another, in degrees.
order: 22
ns: IVec2
member: heading
---

The angle from <code>from</code> to <code>to</code> in whole degrees: 0 is +x, 90 is +y (screen y grows downward). Pair it with <code>Angle.diff_degrees</code> for an arc test.

```ludic
# doc-check: skip — illustrative
let to_foe = IVec2.heading(hero, foe)
```
