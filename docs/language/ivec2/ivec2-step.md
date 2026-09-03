---
id: ivec2-step
name: IVec2.step
category: ivec2
kind: namespace-method
tokens: IVec2.step
sig: IVec2.step(degrees) -> IVec2
tip: A -1/0/1 unit step along a heading.
order: 24
ns: IVec2
member: step
---

The heading snapped to the eight compass steps: each component is -1, 0 or 1. A roll or knockback direction from an aim angle.

```ludic
# doc-check: skip — illustrative
let direction = IVec2.step(TopDown.of(player).aim_angle)
```
