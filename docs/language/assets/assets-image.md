---
id: assets-image
name: Assets.image
category: assets
kind: namespace-method
tokens: Assets.image
sig: Assets.image(path) -> int
tip: Load a whole image file as one sprite; returns its id.
order: 1
ns: Assets
member: image
---

Loads the image at <code>path</code> as a single atlas sprite the size of the image, returning its id — the namespaced replacement for a bare <code>png_load</code>. Draw it with <a href="sprite-draw"><code>Sprite.draw</code></a>.
