---
id: fn-world_field_id
name: world_field_id
category: ecs
kind: builtin
tokens: world_field_id
sig: world_field_id(property, name) -> int
tip: Resolve a field name within a property to its numeric index.
order: 50
---

<code>world_field_id</code> resolves a field name <b>within</b> a given property to its numeric index, which is what `world_get` and `world_set` use to pick which field to read or write. You pass a property id (from `world_prop_id`) and the field's name, and get back its index (negative if the property has no such field). Together the trio `world_prop_id` → `world_field_id` → `world_get`/`world_set` lets a mod or tool touch any field on any instance entirely by name, without the property being known at compile time.

Parameters:
- `property` — the property id, from `world_prop_id`
- `name` — the field's name within that property, e.g. `"column"`

```ludic
program ResolveField {
  property Position { column: int = 0, row: int = 0 }
  model Player { Position }

  handler Boot phase Start {
    spawn Hero { Position { column: 3, row: 3 } }
  }

  handler Inspect phase Update {
    let position_property = world_prop_id("Position")
    let column_field = world_field_id(position_property, "column")
    Screen.status(str(column_field))
  }
}
```
