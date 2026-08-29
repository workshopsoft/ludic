---
id: fn-world_register_prop
name: world_register_prop
category: ecs
kind: builtin
tokens: world_register_prop
sig: world_register_prop(name, fields) -> int
tip: Register a brand-new property at runtime and get its id (dynamic ECS).
order: 50
---

<code>world_register_prop</code> declares a <b>brand-new</b> property at runtime — one not present in the compiled program — and returns its property id. This is the dynamic-ECS entry point for mods: a mod can add its own component to the world, then `world_attach_dyn` it onto instances and read and write its fields with `world_get`/`world_set`. You give the property a name and its number of fields; the returned id then works everywhere a compiled property id does. Compiled programs that need no runtime-defined properties never call this — they declare `property` blocks at compile time instead.

Parameters:
- `name` — the new property's name, as a string
- `fields` — how many integer fields it has

```ludic
program ModComponent {
  property Position { column: int = 0, row: int = 0 }
  model Player { Position }

  handler Boot phase Start {
    spawn Hero { Position { column: 4, row: 4 } }
    let stamina_property = world_register_prop("Stamina", 1)
    Screen.status(string(stamina_property))
  }
}
```
