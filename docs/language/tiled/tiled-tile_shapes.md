---
id: tiled-tile_shapes
name: Tiled.tile_shapes
category: tiled
kind: namespace-method
tokens: Tiled.tile_shapes
sig: Tiled.tile_shapes(map, gid: int) -> int
tip: Whether a GID's tile has a collision shape.
order: 16
ns: Tiled
member: tile_shapes
---

Returns <code>1</code> if the tile a GID resolves to carries a per-tile <code>&lt;objectgroup&gt;</code> with at least one collision shape (rectangle/ellipse/polygon/point), else <code>0</code> — the precise collision source in the P2 priority order.
