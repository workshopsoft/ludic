---
id: tiled-world_map
name: Tiled.world_map
category: tiled
kind: namespace-method
tokens: Tiled.world_map
sig: Tiled.world_map(world, index: int) -> value
tip: A world member map by index.
order: 39
ns: Tiled
member: world_map
---

Returns member map <code>index</code> of a world as a <a href="value"><code>Value</code></a> object — its <code>fileName</code> and world <code>x</code>/<code>y</code> offset — so the caller can load each map and draw it at its place.
