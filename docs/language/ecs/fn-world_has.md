---
id: fn-world_has
name: world_has
category: ecs
kind: builtin
tokens: world_has
sig: world_has(target, property) -> bool
tip: Test whether a model instance currently carries a property.
order: 50
---

<code>world_has</code> tests whether a model instance currently carries a given property, returning a boolean. It is the reflection-ABI equivalent of the membership test a `query` performs implicitly, and the safe guard to run before a `world_get`/`world_set` on a property an instance might not have. A property that has been `disable`d reads as absent here (its has-flag is clear), while one that is merely present with default values reads as present. Pass the target instance and the property id from `world_prop_id`.

Parameters:
- `target` — the model instance to test, an `entity` handle
- `property` — the property id, from `world_prop_id`

```ludic
program CheckProperty {
  property Position { column: int = 0, row: int = 0 }
  property Shield   { amount: int = 0 }
  model Player { Position, Shield }

  handler Boot phase Start {
    spawn Hero { Position { column: 1, row: 1 }; Shield { amount: 2 } }
  }

  handler Inspect phase Update {
    let shield_property = world_prop_id("Shield")
    for (position) in query [Position, {Player}] {
      if world_has(self(), shield_property) { Screen.status("shielded") }
    }
  }
}
```
