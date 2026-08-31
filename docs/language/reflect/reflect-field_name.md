---
id: reflect-field_name
name: Reflect.field_name
category: reflect
kind: namespace-method
tokens: Reflect.field_name
sig: Reflect.field_name(prop, index) -> string
tip: The name of the field at an index within a property.
order: 6
ns: Reflect
member: field_name
---

Returns the name of the field at <code>index</code> within property <code>prop</code> (<code>0 .. Reflect.field_count(prop)</code>), or the empty string if out of range. The key half of a generic serializer or inspector row.

Parameters:
- `prop` — a property id (from <a href="reflect-prop"><code>Reflect.prop</code></a>)
- `index` — the field index

```ludic
program Demo {
  property Health { hp: int = 0, max: int = 0 }
  model Unit { Health }
  entry {
    let H = Reflect.prop("Health")
    print(Reflect.field_name(H, 0))   # hp
  }
}
```
