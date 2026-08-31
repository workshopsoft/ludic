---
id: reflect-prop
name: Reflect.prop
category: reflect
kind: namespace-method
tokens: Reflect.prop
sig: Reflect.prop(name) -> int
tip: The property id for a property name, or -1 if unknown.
order: 1
ns: Reflect
member: prop
---

Resolves a property name to its stable id, or <code>-1</code> if no such property exists. The id is what every other <code>Reflect.*</code> (and <a href="query"><code>Query</code></a>) call takes. Same as <a href="world-prop_id"><code>World.prop_id</code></a>, under the reflection namespace.

Parameters:
- `name` — the property name

```ludic
program Demo {
  property Health { hp: int = 0 }
  model Unit { Health }
  entry {
    let H = Reflect.prop("Health")
    print(H)
  }
}
```
