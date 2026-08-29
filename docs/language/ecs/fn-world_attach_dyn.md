---
id: fn-world_attach_dyn
name: world_attach_dyn
category: ecs
kind: builtin
tokens: world_attach_dyn
sig: world_attach_dyn(target, property)
tip: Attach a property to an instance by numeric id at runtime (dynamic ECS).
order: 50
---

<code>world_attach_dyn</code> adds a property to a live instance by numeric id, the reflection-ABI counterpart of the static `attach Prop on instance`. It is the tool a mod uses to grant a runtime-registered property (from `world_register_prop`) — or any property known only by id — to an instance, after which the instance's fields can be written with `world_set`. It returns nothing and sets the instance's has-flag for that property. Pair it with `world_detach_dyn` to remove. In ordinary compiled code, prefer the `attach` statement, which also fires `@OnAttach` hooks and seeds field overrides.

Parameters:
- `target` — the model instance to modify, an `entity` handle
- `property` — the property id to attach, from `world_prop_id` or `world_register_prop`

```ludic
program GrantComponent {
  property Position { column: int = 0, row: int = 0 }
  model Player { Position }

  handler Boot phase Start {
    spawn Hero { Position { column: 4, row: 4 } }
    let stamina_property = world_register_prop("Stamina", 1)
    for (position) in query [Position, {Player}] {
      world_attach_dyn(self(), stamina_property)
    }
  }
}
```
