---
id: sprite-draw_scaled
name: Sprite.draw_scaled
category: sprite
kind: namespace-method
tokens: Sprite.draw_scaled
sig: Sprite.draw_scaled(id, x, y, scale)
tip: Blit an atlas sprite scaled by an integer factor.
order: 7
ns: Sprite
member: draw_scaled
---

Draws atlas sprite <code>id</code> at <code>(x, y)</code> scaled by the integer <code>scale</code> (each source pixel becomes a <code>scale x scale</code> block). For sub-integer / camera zoom, use <a href="camera-zoom"><code>Camera.zoom</code></a> around a plain <a href="sprite-draw"><code>Sprite.draw</code></a>.
