---
id: fn-world_spawn
name: world_spawn
category: ecs
kind: builtin
tokens: world_spawn
sig: world_spawn(model) -> entity
tip: Spawn an instance of a model chosen by numeric id at runtime.
order: 50
---

<code>world_spawn</code> creates a new instance of a model chosen by numeric id and returns its `entity` handle — the reflection-ABI counterpart of the static `spawn Label { … }`. Because the model is given as an id (from `world_model_id`) rather than a name written in source, a mod or tool can decide <b>at runtime</b> which kind to create. The new instance is seeded exactly as the static spawn would seed it — every property in the model attached with default field values — after which you can set fields with `world_set`. Use the ordinary `spawn` statement in normal handler code; reach for `world_spawn` when the kind is data, not a literal.

Parameters:
- `model` — the model id to instantiate, from `world_model_id`

```ludic
program Reinforcements {
  property Position { column: int = 0, row: int = 0 }
  model Enemy { Position }

  handler Reinforce phase Update {
    if Input.key() == ' ' {
      let enemy_model = world_model_id("Enemy")
      let new_enemy = world_spawn(enemy_model)
      Screen.status(string(new_enemy))
    }
  }
}
```
