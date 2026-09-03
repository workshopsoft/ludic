---
id: map-is_solid
name: Map.is_solid
category: map
kind: namespace-method
tokens: Map.is_solid
sig: Map.is_solid(x: tx, y: ty) -> bool
tip: Is a cell solid, per the Solids config?
order: 16
ns: Map
member: is_solid
---

True when the cell holds one of the solid glyphs the <code>Solids</code> configuration names (<code>wall</code>, <code>solid2</code>), or lies outside the map. With no <code>Solids</code> entity nothing is solid. The move system and the projectiles use the same answer.

```ludic
# doc-check: skip — illustrative
if Map.is_solid(x: tile.x, y: tile.y) { continue }
```
