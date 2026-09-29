---
id: kw-shows
name: shows
category: scenes
kind: keyword
tokens: shows
sig: scene Name shows Menu { }
tip: The ui this scene opens, renders and closes by itself.
order: 51
---

<code>shows Menu</code> in a scene's header hands a <code>ui</code> to the engine: it is opened when the scene is entered, drawn every frame and closed when it is left, so the scene needs no handler for it.
