---
id: fn-world_kind
name: world_kind
category: ecs
kind: builtin
tokens: world_kind
sig: world_kind(target) -> int
tip: The model id of an instance — which kind of thing it is.
order: 50
---

<code>world_kind</code> returns the model id of a given instance — that is, which kind of thing it is — as an `int`. Compare the result against ids from `world_model_id` to branch generically on an instance's kind without knowing it at compile time, the reflection-ABI stand-in for the `{Model}` tag filter in a static `query`. It is the natural partner of `world_query_next` when you walk instances by id and need to tell players from enemies. Pass the instance handle you want to classify.

Parameters:
- `target` — the model instance to classify, an `entity` handle

```ludic
program Classify {
  property Position { column: int = 0, row: int = 0 }
  model Player { Position }
  model Enemy  { Position }

  handler Boot phase Start {
    spawn Hero  { Position { column: 2, row: 2 } }
    spawn Grunt { Position { column: 8, row: 2 } }
  }

  handler Inspect phase Update {
    let enemy_model = world_model_id("Enemy")
    for (position) in query [Position] {
      if world_kind(self()) == enemy_model { Screen.status("found an enemy") }
    }
  }
}
```
