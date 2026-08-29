---
id: fn-world_detach_dyn
name: world_detach_dyn
category: ecs
kind: builtin
tokens: world_detach_dyn
sig: world_detach_dyn(target, property)
tip: Detach a property from an instance by numeric id at runtime (dynamic ECS).
order: 50
---

<code>world_detach_dyn</code> removes a property from a live instance by numeric id, the reflection-ABI counterpart of the static `detach Prop on instance`. It clears the instance's has-flag for that property so queries and `world_has` no longer see it, and returns nothing. Use it to take back a runtime-registered or id-only property a mod previously granted with `world_attach_dyn`. In ordinary compiled code, prefer the `detach` statement, which also fires the `@OnDetach` hook before the flag clears.

Parameters:
- `target` — the model instance to modify, an `entity` handle
- `property` — the property id to detach, from `world_prop_id` or `world_register_prop`

```ludic
program RevokeComponent {
  property Position { column: int = 0, row: int = 0 }
  model Player { Position }

  handler Boot phase Start {
    spawn Hero { Position { column: 4, row: 4 } }
  }

  handler DropStamina phase Update {
    let stamina_property = world_prop_id("Stamina")
    if stamina_property >= 0 {
      for (position) in query [Position, {Player}] {
        world_detach_dyn(self(), stamina_property)
      }
    }
  }
}
```
