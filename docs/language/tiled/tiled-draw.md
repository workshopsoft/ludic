---
id: tiled-draw
name: Tiled.draw
category: tiled
kind: namespace-method
tokens: Tiled.draw
sig: Tiled.draw(map, camx: int, camy: int) -> void
tip: Draw every visible tile layer.
order: 10
ns: Tiled
member: draw
---

Draws every visible tile layer in file order to the framebuffer, offset by the camera <code>(camx, camy)</code>, blitting each tile from its tileset image and applying the GID's flip flags at draw time.
