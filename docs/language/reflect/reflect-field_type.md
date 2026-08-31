---
id: reflect-field_type
name: Reflect.field_type
category: reflect
kind: namespace-method
tokens: Reflect.field_type
sig: Reflect.field_type(prop, index) -> string
tip: The type name of the field at an index within a property.
order: 7
ns: Reflect
member: field_type
---

Returns the declared type name of the field at <code>index</code> within property <code>prop</code> — <code>"int"</code>, <code>"fixed"</code>, <code>"bool"</code>, and so on. A serializer uses it to format each value correctly, and an inspector uses it to pick the right editor widget.

Parameters:
- `prop` — a property id (from <a href="reflect-prop"><code>Reflect.prop</code></a>)
- `index` — the field index

```ludic
program Demo {
  property Velocity { dx: fixed = 0.0, dy: fixed = 0.0 }
  model Mover { Velocity }
  entry {
    let V = Reflect.prop("Velocity")
    print(Reflect.field_type(V, 0))   # fixed
  }
}
```
