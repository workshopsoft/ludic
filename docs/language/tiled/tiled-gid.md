---
id: tiled-gid
name: Tiled.gid
category: tiled
kind: namespace-method
tokens: Tiled.gid
sig: Tiled.gid(map, layer: int, x: int, y: int) -> int
tip: The raw GID at a cell in a tile layer.
order: 4
ns: Tiled
member: gid
---

Returns the raw global tile id (with its flip flags still set) at cell <code>(x,y)</code> in tile <code>layer</code>, or <code>0</code> (empty) out of bounds or for a non-tile layer.
