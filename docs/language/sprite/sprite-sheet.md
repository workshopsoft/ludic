---
id: sprite-sheet
name: Sprite.sheet
category: sprite
kind: namespace-method
tokens: Sprite.sheet
sig: Sprite.sheet(path, cellw, cellh) -> int
tip: Load a spritesheet and remember its cell grid; returns a sheet handle.
order: 1
ns: Sprite
member: sheet
---

Loads the PNG at <code>path</code> and records that its cells are <code>cellw x cellh</code> px, returning a sheet <em>handle</em>. Address its cells with <a href="sprite-cell"><code>Sprite.cell</code></a> / <a href="sprite-cell_span"><code>Sprite.cell_span</code></a>. The whole image is kept (variable size), so cells are not restricted to the 16x16 sprite table.
