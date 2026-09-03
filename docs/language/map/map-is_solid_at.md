---
id: map-is_solid_at
name: Map.is_solid_at
category: map
kind: namespace-method
tokens: Map.is_solid_at
sig: Map.is_solid_at(x: px, y: py) -> bool
tip: Is the cell under a pixel position solid?
order: 17
ns: Map
member: is_solid_at
---

<code>Map.is_solid</code> for a pixel position, using the tile size from the <code>Solids</code> config.

```ludic
# doc-check: skip — illustrative
if not Map.is_solid_at(x: pushed.x, y: pushed.y) { Position.x = pushed.x }
```
