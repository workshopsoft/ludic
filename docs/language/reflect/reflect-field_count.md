---
id: reflect-field_count
name: Reflect.field_count
category: reflect
kind: namespace-method
tokens: Reflect.field_count
sig: Reflect.field_count(prop) -> int
tip: How many fields a property has.
order: 5
ns: Reflect
member: field_count
---

Returns the number of fields in property <code>prop</code>. Walk <code>0 .. Reflect.field_count(prop)</code> with <a href="reflect-field_name"><code>Reflect.field_name</code></a> and <a href="reflect-field_type"><code>Reflect.field_type</code></a> to enumerate a component's shape.

Parameters:
- `prop` — a property id (from <a href="reflect-prop"><code>Reflect.prop</code></a>)

```ludic
program Demo {
  property Health { hp: int = 0, max: int = 0 }
  model Unit { Health }
  entry {
    print(Reflect.field_count(Reflect.prop("Health")))   # 2
  }
}
```
