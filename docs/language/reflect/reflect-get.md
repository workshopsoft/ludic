---
id: reflect-get
name: Reflect.get
category: reflect
kind: namespace-method
tokens: Reflect.get
sig: Reflect.get(entity, prop, field) -> int
tip: Read one field of an entity by (prop, field) id.
order: 8
ns: Reflect
member: get
---

Reads the value of field <code>field</code> of property <code>prop</code> on <code>entity</code>, as an <code>int</code>. A <code>fixed</code> field comes back as its raw Q16.16 bits (the same integer <code>fixed</code> stores), so a generic reader can move it without interpreting it. Same as <a href="world-get"><code>World.get</code></a>, under the reflection namespace.

Parameters:
- `entity` — the entity to read
- `prop` — a property id (from <a href="reflect-prop"><code>Reflect.prop</code></a>)
- `field` — a field id (from <a href="reflect-field"><code>Reflect.field</code></a>)

```ludic
program Demo {
  property Health { hp: int = 0 }
  model Unit { Health }
  entry {
    spawn Unit { Health { hp: 7 } }
    let H = Reflect.prop("Health")
    print(Reflect.get(0, H, Reflect.field(H, "hp")))   # 7
  }
}
```
