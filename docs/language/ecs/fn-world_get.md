---
id: fn-world_get
name: world_get
category: ecs
kind: builtin
tokens: world_get
sig: world_get(target, property, field) -> int
tip: Read one field of a model instance by numeric id (reflection ABI).
order: 50
---

<code>world_get</code> reads a single field of a model instance entirely by numeric id, returning its value as an `int`. It is the id-based counterpart to the ordinary `position.column` field access that queries give you — used when the property is not known at compile time, as in a mod or a generic tool. You supply the target instance (an `entity`), the property id (from `world_prop_id`), and the field id (from `world_field_id`); the result is the stored value. Pair it with `world_set` to write. Reading a field of an instance that lacks the property is not meaningful, so guard with `world_has` first if unsure.

Parameters:
- `target` — the model instance to read from, an `entity` handle
- `property` — the property id, from `world_prop_id`
- `field` — the field id within that property, from `world_field_id`

```ludic
program ReadField {
  property Position { column: int = 0, row: int = 0 }
  model Player { Position }

  handler Boot phase Start {
    spawn Hero { Position { column: 7, row: 2 } }
  }

  handler Inspect phase Update {
    let position_property = world_prop_id("Position")
    let column_field = world_field_id(position_property, "column")
    for (position) in query [Position, {Player}] {
      let value = world_get(self(), position_property, column_field)
      Screen.status(str(value))
    }
  }
}
```
