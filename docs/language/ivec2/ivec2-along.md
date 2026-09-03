---
id: ivec2-along
name: IVec2.along
category: ivec2
kind: namespace-method
tokens: IVec2.along
sig: IVec2.along(origin, degrees, distance) -> IVec2
tip: The point a distance along a heading.
order: 23
ns: IVec2
member: along
---

The point <code>distance</code> pixels from <code>origin</code> along <code>degrees</code> — the tip of an aim line, the centre of a melee arc.

```ludic
# doc-check: skip — illustrative
let tip = IVec2.along(hero, aim, 18)
```
