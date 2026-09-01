---
id: tiled-collide
name: Tiled.collide
category: tiled
kind: namespace-method
tokens: Tiled.collide
sig: Tiled.collide(map, layer: int) -> void
tip: Drive collision from per-tile metadata.
order: 14
ns: Tiled
member: collide
---

Projects a layer to the byte tilemap driving collision from per-tile metadata alone — a tile's <code>&lt;objectgroup&gt;</code> hitbox or its <code>solid</code>/<code>oneway</code>/<code>trigger</code> property — so a tile with no collision metadata stays passable. Use this to drive collision from a visual layer; <a href="tiled-project"><code>Tiled.project</code></a> is the designated-collision-layer form where any non-zero GID is solid.
