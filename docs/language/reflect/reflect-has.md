---
id: reflect-has
name: Reflect.has
category: reflect
kind: namespace-method
tokens: Reflect.has
sig: Reflect.has(entity, prop) -> bool
tip: Does an entity carry a property?
order: 10
ns: Reflect
member: has
---

Returns whether <code>entity</code> carries property <code>prop</code>. A generic walker checks it before reading a component's fields, so it visits only the components an entity actually has.

Parameters:
- `entity` — the entity to test
- `prop` — a property id (from <a href="reflect-prop"><code>Reflect.prop</code></a>)

```ludic
program Demo {
  property Health { hp: int = 0 }
  model Unit { Health }
  entry {
    spawn Unit { Health { hp: 7 } }
    if Reflect.has(0, Reflect.prop("Health")) { print(1) }
  }
}
```
