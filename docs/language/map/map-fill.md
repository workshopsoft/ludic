---
id: map-fill
name: Map.fill
category: map
kind: namespace-method
tokens: Map.fill
sig: Map.fill(glyph: g)
tip: Every cell becomes the glyph.
order: 12
ns: Map
member: fill
---

Fills the whole map with one glyph — the first stroke of a generated room.

```ludic
# doc-check: skip — illustrative
Map.size(20, 15)
Map.fill(glyph: '.')
```
