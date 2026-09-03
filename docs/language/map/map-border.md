---
id: map-border
name: Map.border
category: map
kind: namespace-method
tokens: Map.border
sig: Map.border(glyph: g)
tip: The outermost ring of cells.
order: 14
ns: Map
member: border
---

Writes <code>glyph</code> along the map's edge — the arena wall around a generated room.

```ludic
# doc-check: skip — illustrative
Map.fill(glyph: '.')
Map.border(glyph: '#')
```
