---
id: reflect-field
name: Reflect.field
category: reflect
kind: namespace-method
tokens: Reflect.field
sig: Reflect.field(prop, name) -> int
tip: The field id of a named field within a property, or -1.
order: 2
ns: Reflect
member: field
---

Resolves a field name within property <code>prop</code> to its field id (index), or <code>-1</code> if the property has no such field. Pair it with <a href="reflect-get"><code>Reflect.get</code></a>/<a href="reflect-set"><code>Reflect.set</code></a> to read or write that field.

Parameters:
- `prop` — a property id (from <a href="reflect-prop"><code>Reflect.prop</code></a>)
- `name` — the field name

```ludic
program Demo {
  property Health { hp: int = 0, max: int = 0 }
  model Unit { Health }
  entry {
    let H  = Reflect.prop("Health")
    let mx = Reflect.field(H, "max")
    print(mx)
  }
}
```
