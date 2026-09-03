---
id: map-to_tile
name: Map.to_tile
category: map
kind: namespace-method
tokens: Map.to_tile
sig: Map.to_tile(pixel: IVec2) -> IVec2
tip: The tile under a pixel position.
order: 21
ns: Map
member: to_tile
---

Divides a pixel position by the tile size of the <code>Solids</code> config.

```ludic
# doc-check: skip — illustrative
let tile = Map.to_tile(pixel: Collider.center(player))
```
