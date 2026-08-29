---
id: kw-scene
name: scene
category: scenes
kind: keyword
tokens: scene
sig: scene Name [start] { on enter{} on exit{} layer … }
tip: A mutually-exclusive game state.
order: 0
---

A mutually-exclusive game state. Mark one <code>start</code>.

```ludic
scene Title start { on enter { … } layer Main { … } }
```
