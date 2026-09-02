---
id: sprite-cell
name: Sprite.cell
category: sprite
kind: namespace-method
tokens: Sprite.cell
sig: Sprite.cell(sheet, col, row) -> int
tip: One cell of a sheet, by grid coords; returns a sprite id.
order: 2
ns: Sprite
member: cell
---

Returns a sprite id for the cell at column <code>col</code>, row <code>row</code> of <code>sheet</code> (the sub-rect <code>(col*cellw, row*cellh, cellw, cellh)</code>). Draw it with <a href="sprite-draw"><code>Sprite.draw</code></a>.
