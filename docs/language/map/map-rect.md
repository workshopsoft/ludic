---
id: map-rect
name: Map.rect
category: map
kind: namespace-method
tokens: Map.rect
sig: Map.rect(x: tx, y: ty, width: w, height: h, glyph: g)
tip: Fill a rectangle of cells.
order: 13
ns: Map
member: rect
---

Writes <code>glyph</code> into every cell of the rectangle; cells outside the map are skipped. A wall slab, a carved corridor, a cleared lane.

```ludic
# doc-check: skip — illustrative
Map.rect(x: 9, y: 1, width: 2, height: 13, glyph: '.')   # a lane the cover never blocks
```
