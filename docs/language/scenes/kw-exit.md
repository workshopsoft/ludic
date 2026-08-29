---
id: kw-exit
name: exit
category: scenes
kind: keyword
tokens: exit
sig: on exit { … }
tip: The scene-exit hook — runs once as a scene is left.
order: 4
---

`exit` names the body of a scene's exit hook, written `on exit { … }`. It runs <b>once</b> when the scene is left — on a `become Other`, the leaving scene's `on exit` runs first, then the active scene switches and the new scene's `on enter` runs. Use it to tear down what the scene created so it does not leak into the next state: despawn the scene's models, hide a menu, save progress. Like `on enter`, it is a lifecycle hook rather than a phase and holds plain statements, not `phase` handlers.

```ludic
program ExitHookExample {
  property Position { column: int = 0, row: int = 0 }
  model Enemy { Position }

  scene Battle start {
    on enter { spawn Enemy { Position { column: 8, row: 4 } } }
    on exit {
      for (any_position) in query [Position, {Enemy}] { despawn self() }
    }
    layer Fight {
      handler LeaveBattle phase Update {
        if Input.key() == 'q' { become Overworld }
      }
      handler DrawBattle phase Render {
        Screen.clear(Color.Crimson)
        Screen.show()
      }
    }
  }

  scene Overworld {
    layer World {
      handler DrawWorld phase Render {
        Screen.clear(Color.MidnightBlue)
        Screen.show()
      }
    }
  }
}
```
