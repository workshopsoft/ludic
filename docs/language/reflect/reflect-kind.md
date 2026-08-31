---
id: reflect-kind
name: Reflect.kind
category: reflect
kind: namespace-method
tokens: Reflect.kind
sig: Reflect.kind(entity) -> int
tip: The model id of an entity.
order: 11
ns: Reflect
member: kind
---

Returns the model (archetype) id of <code>entity</code> — which kind of thing it is. Compare it against <a href="reflect-model"><code>Reflect.model</code></a> to branch on an entity's type, or use it to label a save record. Same as <a href="world-kind"><code>World.kind</code></a>, under the reflection namespace.

Parameters:
- `entity` — the entity to identify

```ludic
program Demo {
  property Health { hp: int = 0 }
  model Unit { Health }
  entry {
    spawn Unit { Health { hp: 7 } }
    if Reflect.kind(0) == Reflect.model("Unit") { print(1) }
  }
}
```
