---
id: sprite-define
name: Sprite.define
category: sprite
kind: namespace-method
tokens: Sprite.define
sig: Sprite.define(name, sheet, col, row) -> int
tip: Name a cell for later lookup; returns its sprite id.
order: 4
ns: Sprite
member: define
---

Creates the cell at <code>(col, row)</code> of <code>sheet</code> and registers it under <code>name</code>, returning its sprite id. Look it up later with <a href="sprite-named"><code>Sprite.named</code></a> — content data (item/tile names) can drive rendering without hard-coded ids.
