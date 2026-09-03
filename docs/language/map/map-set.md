---
id: map-set
name: Map.set
category: map
kind: namespace-method
tokens: Map.set
sig: Map.set(x: tx, y: ty, glyph: g)
tip: Write one cell in place.
order: 11
ns: Map
member: set
---

Writes one cell of the tilemap. A game edits the engine's grid directly — carving a door, placing a pillar — instead of keeping its own copy and re-stamping rows.

```ludic
# doc-check: skip — illustrative
Map.set(x: 9, y: 0, glyph: '.')      # open the north door
```
