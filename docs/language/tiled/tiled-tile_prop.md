---
id: tiled-tile_prop
name: Tiled.tile_prop
category: tiled
kind: namespace-method
tokens: Tiled.tile_prop
sig: Tiled.tile_prop(map, gid: int, name: string) -> int
tip: Whether a GID's tile carries a bool property.
order: 13
ns: Tiled
member: tile_prop
---

Returns <code>1</code> if the tile the GID resolves to carries a custom bool property <code>name</code> set to true, else <code>0</code> — the property convention (<code>solid</code>/<code>oneway</code>/<code>trigger</code>) the collision projection reads.
