---
id: tiled-cell_y
name: Tiled.cell_y
category: tiled
kind: namespace-method
tokens: Tiled.cell_y
sig: Tiled.cell_y(map, x: int, y: int) -> int
tip: The screen y of a tile cell for the map orientation.
order: 31
ns: Tiled
member: cell_y
---

Returns the screen y of tile cell <code>(x,y)</code>: orthogonal <code>y·tileh</code>, isometric <code>(x+y)·tileh/2</code>, staggered <code>y·tileh/2</code>, hexagonal rows stepping by <code>(tileh+hexsidelength)/2</code>.
