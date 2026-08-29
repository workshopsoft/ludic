---
id: fn-world_model_id
name: world_model_id
category: ecs
kind: builtin
tokens: world_model_id
sig: world_model_id(name) -> int
tip: Resolve a model's name to its stable numeric id.
order: 50
---

<code>world_model_id</code> looks up a model by name and returns its stable numeric id, or a negative value if no model of that name exists. It is part of Ludic's reflection ABI — the dynamic, id-based view of the world that mods and tools use alongside the static `spawn`/`query` forms. You typically resolve a name to an id once and then feed that id to id-based calls such as `world_spawn` or `world_kind`. Because the id is stable for a given build, it is safe to cache in a `var`.

Parameters:
- `name` — the model's name, as a string, e.g. `"Player"`

```ludic
program ResolveModel {
  property Position { column: int = 0, row: int = 0 }
  model Player { Position }

  handler Boot phase Start {
    spawn Hero { Position { column: 3, row: 3 } }
  }

  handler Inspect phase Update {
    let player_model = world_model_id("Player")
    Screen.status(string(player_model))
  }
}
```
