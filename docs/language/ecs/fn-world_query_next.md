---
id: fn-world_query_next
name: world_query_next
category: ecs
kind: builtin
tokens: world_query_next
sig: world_query_next(property, cursor) -> entity
tip: Step to the next instance carrying a property, walking the world by id.
order: 50
---

<code>world_query_next</code> walks the world by ascending instance id, returning the next live instance at or after the cursor that carries the given property, or a negative value when there are no more. It is the reflection-ABI equivalent of a `for (…) in query [Property]` loop, expressed as an explicit step so a mod or tool can iterate matching instances by id. Drive it with a loop: start the cursor at `0`, and after each hit advance the cursor to one past the returned id before calling again. Pass the property id from `world_prop_id`.

Parameters:
- `property` — the property id to match, from `world_prop_id`
- `cursor` — the id to start scanning from; advance it past each hit to continue

```ludic
program WalkInstances {
  property Position { column: int = 0, row: int = 0 }
  model Enemy { Position }

  handler Boot phase Start {
    spawn GruntA { Position { column: 2, row: 2 } }
    spawn GruntB { Position { column: 5, row: 2 } }
  }

  handler Sweep phase Update {
    let position_property = world_prop_id("Position")
    var cursor = 0
    var found = world_query_next(position_property, cursor)
    while found >= 0 {
      cursor = found + 1
      found = world_query_next(position_property, cursor)
    }
  }
}
```
