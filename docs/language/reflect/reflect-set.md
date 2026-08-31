---
id: reflect-set
name: Reflect.set
category: reflect
kind: namespace-method
tokens: Reflect.set
sig: Reflect.set(entity, prop, field, value)
tip: Write one field of an entity by (prop, field) id.
order: 9
ns: Reflect
member: set
---

Writes <code>value</code> into field <code>field</code> of property <code>prop</code> on <code>entity</code>. For a <code>fixed</code> field, pass the raw Q16.16 bits. This is how a generic loader restores saved state and how a debug overlay applies an edit. Same as <a href="world-set"><code>World.set</code></a>, under the reflection namespace.

Parameters:
- `entity` — the entity to modify
- `prop` — a property id (from <a href="reflect-prop"><code>Reflect.prop</code></a>)
- `field` — a field id (from <a href="reflect-field"><code>Reflect.field</code></a>)
- `value` — the integer value to store

```ludic
program Demo {
  property Health { hp: int = 0 }
  model Unit { Health }
  entry {
    spawn Unit { Health { hp: 7 } }
    let H = Reflect.prop("Health")
    Reflect.set(0, H, Reflect.field(H, "hp"), 99)
    print(Reflect.get(0, H, 0))   # 99
  }
}
```
