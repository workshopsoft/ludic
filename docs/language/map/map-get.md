---
id: map-get
name: Map.get
category: map
kind: namespace-method
tokens: Map.get
sig: Map.get(x: tx, y: ty) -> int
tip: The glyph at a cell ('#' outside the map).
order: 10
ns: Map
member: get
---

Reads one cell of the tilemap by tile coordinates; outside the map it answers <code>'#'</code>, so the edge of the world reads as wall.

```ludic
# doc-check: skip — illustrative
if Map.get(x: 3, y: 4) == '.' { … }
```
