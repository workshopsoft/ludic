---
id: sprite-named
name: Sprite.named
category: sprite
kind: namespace-method
tokens: Sprite.named
sig: Sprite.named(name) -> int
tip: Look up a named sprite's id, or -1.
order: 5
ns: Sprite
member: named
---

Returns the sprite id registered under <code>name</code> by <a href="sprite-define"><code>Sprite.define</code></a>, or <code>-1</code> if none. Names compare by content.
