---
id: fn-world_prop_id
name: world_prop_id
category: ecs
kind: builtin
tokens: world_prop_id
sig: world_prop_id(name) -> int
tip: Resolve a property's name to its stable numeric id.
order: 50
---

<code>world_prop_id</code> resolves a property by name to its stable numeric id, returning a negative value when no such property exists. It is the entry point to the reflection ABI's field access: pass the returned property id to `world_has`, `world_count`, `world_get`/`world_set` (together with a field id from `world_field_id`), and the dynamic attach/detach and query calls. Resolve the id once and cache it in a `var` rather than looking it up every frame. This id-based view complements the static `query [...]`, which is how ordinary handlers reach properties by name.

Parameters:
- `name` — the property's name, as a string, e.g. `"Position"`

```ludic
program ResolveProperty {
  property Position { column: int = 0, row: int = 0 }
  model Player { Position }

  handler Boot phase Start {
    spawn Hero { Position { column: 3, row: 3 } }
  }

  handler Inspect phase Update {
    let position_property = world_prop_id("Position")
    Screen.status(str(position_property))
  }
}
```
