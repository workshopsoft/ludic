---
id: fn-world_set
name: world_set
category: ecs
kind: builtin
tokens: world_set
sig: world_set(target, property, field, value)
tip: Write one field of a model instance by numeric id (reflection ABI).
order: 50
---

<code>world_set</code> writes a single field of a model instance by numeric id — the id-based counterpart to an ordinary `position.column = …` assignment, used when the property is not known at compile time. You give the target instance, the property id (from `world_prop_id`), the field id (from `world_field_id`), and the new value; the value is stored just as a direct assignment would. It returns nothing. Together with `world_get`, `world_has`, and the resolver functions, it lets a mod or tool mutate any field on any instance generically, which is how the reflection ABI mirrors the compiled `query`/field access at runtime.

Parameters:
- `target` — the model instance to write to, an `entity` handle
- `property` — the property id, from `world_prop_id`
- `field` — the field id within that property, from `world_field_id`
- `value` — the new integer value to store

```ludic
program WriteField {
  property Position { column: int = 0, row: int = 0 }
  model Player { Position }

  handler Boot phase Start {
    spawn Hero { Position { column: 0, row: 0 } }
  }

  handler Nudge phase Update {
    let position_property = world_prop_id("Position")
    let column_field = world_field_id(position_property, "column")
    for (position) in query [Position, {Player}] {
      world_set(self(), position_property, column_field, position.column + 1)
    }
  }
}
```
