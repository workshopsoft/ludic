---
id: tiled-spawn
name: Tiled.spawn
category: tiled
kind: namespace-method
tokens: Tiled.spawn
sig: Tiled.spawn(map, object, model: string) -> int
tip: Spawn a Ludic entity from an object.
order: 28
ns: Tiled
member: spawn
---

Opt-in: spawns an entity of <code>model</code> from an <code>object</code> — its <code>Position</code> (if the model has one) takes the object's x/y, and each object custom property sets a like-named int/bool component field through the reflection ABI. Returns the entity, or -1 if the model is unknown. The core load never calls this.
