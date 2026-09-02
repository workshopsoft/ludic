---
id: sprite-draw
name: Sprite.draw
category: sprite
kind: namespace-method
tokens: Sprite.draw
sig: Sprite.draw(id, x, y)
tip: Blit an atlas sprite at (x, y) through the camera/zoom/clip.
order: 6
ns: Sprite
member: draw
---

Draws atlas sprite <code>id</code> with its top-left at <code>(x, y)</code>. Sufficiently-opaque pixels are drawn through <code>rt_put_px</code>, so the camera, zoom and clip apply exactly like <a href="screen-sprite"><code>Screen.sprite</code></a>.
