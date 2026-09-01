---
id: tiled-cell_x
name: Tiled.cell_x
category: tiled
kind: namespace-method
tokens: Tiled.cell_x
sig: Tiled.cell_x(map, x: int, y: int) -> int
tip: The screen x of a tile cell for the map orientation.
order: 30
ns: Tiled
member: cell_x
---

Returns the screen x (before the camera) of tile cell <code>(x,y)</code> under the map's orientation: orthogonal <code>x·tilew</code>, isometric <code>(x−y)·tilew/2</code>, staggered/hexagonal <code>x·tilew</code> with alternate rows shoved half a tile per <code>staggerindex</code>.
