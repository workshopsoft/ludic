---
id: tiled-load
name: Tiled.load
category: tiled
kind: namespace-method
tokens: Tiled.load
sig: Tiled.load(path: string) -> map
tip: Load a map file into the runtime map model.
order: 3
ns: Tiled
member: load
---

Reads a map file (TMX or TMJ), builds the runtime <code>rt_tmap</code> model — resolving external tilesets and loading their images relative to the map file — and projects the designated collision layer (a tile layer named <code>collision</code>/<code>solids</code>/<code>walls</code>) down to the legacy byte tilemap so <a href="grid"><code>Grid</code></a>/<a href="path"><code>Path</code></a> and <code>esys_move</code> keep working unchanged. Returns the loaded map.
