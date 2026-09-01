---
id: tiled-world
name: Tiled.world
category: tiled
kind: namespace-method
tokens: Tiled.world
sig: Tiled.world(path: string) -> value
tip: Read a .world file.
order: 37
ns: Tiled
member: world
---

Reads a Tiled <code>.world</code> file (JSON) — a set of member maps stitched at world offsets — and returns its <a href="value"><code>Value</code></a> tree (<code>maps</code>, <code>patterns</code>, <code>onlyShowAdjacentMaps</code>). Reuses the JSON reader.
