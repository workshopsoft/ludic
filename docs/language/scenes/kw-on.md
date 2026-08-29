---
id: kw-on
name: on enter / on exit
category: scenes
kind: keyword
tokens: on
sig: on enter { … }   on exit { … }
tip: Scene lifecycle hooks that fire as a scene becomes active or is left.
order: 2
---

`on` introduces a scene's lifecycle hooks: `on enter { … }` runs once when the scene becomes active, and `on exit { … }` runs once as it is left. They are hooks, <b>not phases</b> — the place for per-scene setup and teardown that has no equivalent in a mode register. The start scene's `on enter` fires at boot right after the `Start` phase; on a `become Other` the current scene's `on exit` runs, the active scene switches, then the new scene's `on enter` runs. Use `on enter` to spawn the models a scene needs and reset its counters, and `on exit` to tidy up before leaving.

```ludic
program SceneHookExample {
  property Position { column: int = 0, row: int = 0 }
  model Enemy { Position }

  var elapsed_frames: int = 0

  scene Overworld start {
    layer World {
      handler EnterBattle phase Update {
        if Input.key() == 'b' { become Battle }
      }
      handler DrawWorld phase Render {
        Screen.clear(Color.MidnightBlue)
        Screen.show()
      }
    }
  }

  scene Battle {
    on enter {
      elapsed_frames = 0
      spawn Enemy { Position { column: 8, row: 4 } }
    }
    on exit {
      for (any_position) in query [Position, {Enemy}] { despawn self() }
    }
    layer Fight {
      handler DrawBattle phase Render {
        Screen.clear(Color.Crimson)
        for (current_position) in query [Position, {Enemy}] {
          Screen.fill_rectangle(x: current_position.column * 16, y: current_position.row * 16, width: 16, height: 16, color: Color.White)
        }
        Screen.show()
      }
    }
  }
}
```
