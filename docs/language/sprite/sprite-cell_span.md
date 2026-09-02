---
id: sprite-cell_span
name: Sprite.cell_span
category: sprite
kind: namespace-method
tokens: Sprite.cell_span
sig: Sprite.cell_span(sheet, col, row, cols, rows) -> int
tip: A sprite spanning cols x rows cells (tall/wide art).
order: 3
ns: Sprite
member: cell_span
---

Returns a sprite id for a sub-rect spanning <code>cols x rows</code> cells from <code>(col, row)</code> — for a sprite that covers more than one cell (a tall character, a wide object). Same as <a href="sprite-cell"><code>Sprite.cell</code></a> but sized to the span.
