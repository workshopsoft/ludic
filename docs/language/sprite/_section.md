---
id: sprite
title: Sprite
order: 33
---

A namespaced spritesheet / atlas API. <a href="sprite-sheet"><code>Sprite.sheet</code></a> loads one image and remembers its cell grid; <a href="sprite-cell"><code>Sprite.cell</code></a> addresses a cell by grid coords and <a href="sprite-cell_span"><code>Sprite.cell_span</code></a> a sprite that spans more than one cell; <a href="sprite-define"><code>Sprite.define</code></a> / <a href="sprite-named"><code>Sprite.named</code></a> name and look up a cell; <a href="sprite-draw"><code>Sprite.draw</code></a> / <a href="sprite-draw_scaled"><code>Sprite.draw_scaled</code></a> blit it (through the camera / zoom / clip). It stands on the variable-size image loader, so a cell can be any size — not just 16x16. (Distinct from the <code>Sprite</code> engine component of the sprite-render system.)
