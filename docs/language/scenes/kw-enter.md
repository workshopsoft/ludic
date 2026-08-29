---
id: kw-enter
name: enter
category: scenes
kind: keyword
tokens: enter
sig: on enter { … }
tip: The scene-entry hook — runs once as a scene becomes active.
order: 3
---

`enter` names the body of a scene's entry hook, written `on enter { … }`. It runs <b>once</b> each time the scene becomes active — at boot for the `start` scene (right after the `Start` phase), and on every `become Name` that switches into it. This is where a scene builds what it owns: spawn its models, reset its counters, set the tilemap, open a menu. It is a lifecycle hook, not a phase, so it may not contain `phase` handlers; the scene's ongoing behaviour goes in its `layer` handlers instead.

```ludic
program EnterHookExample {
  property Position { column: int = 0, row: int = 0 }
  model Player { Position }

  var score: int = 0

  scene Overworld start {
    on enter {
      score = 0
      spawn Player { Position { column: 5, row: 5 } }
    }
    layer World {
      handler DrawWorld phase Render {
        Screen.clear(Color.MidnightBlue)
        for (current_position) in query [Position, {Player}] {
          Screen.fill_rectangle(x: current_position.column * 16, y: current_position.row * 16, width: 16, height: 16, color: Color.LimeGreen)
        }
        Screen.show()
      }
    }
  }
}
```
