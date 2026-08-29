---
id: phase-update
name: Update
category: phases
kind: phase
tokens: Update
sig: phase Update
tip: The ordinary per-frame game-logic step, run after Input and FixedUpdate.
order: 3
---

`Update` is the everyday game-logic phase, run each frame after `Input` and `FixedUpdate` and before `LateUpdate` and `Render`. It is where most gameplay lives when you are not being strict about determinism: spawn waves on a timer, apply the intent that `Input` recorded, check win/lose conditions, advance animations. Reach for `Update` by default and reserve `FixedUpdate` for the simulation you specifically want reproducible. Because it runs after `Input`, the current frame's key press is already reflected in your program `var`s by the time `Update` reads them.

```ludic
program UpdateExample {
  property Position { column: int = 0, row: int = 0 }
  model Enemy { Position }

  const GRID_WIDTH: int = 20
  var elapsed_frames: int = 0
  var score: int = 0

  handler SpawnWave phase Update {
    elapsed_frames = elapsed_frames + 1
    if elapsed_frames % 30 == 0 {
      let spawn_column = Random.range(low: 0, high: GRID_WIDTH - 1)
      spawn Enemy { Position { column: spawn_column, row: 0 } }
      score = score + 1
    }
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    for (current_position) in query [Position, {Enemy}] {
      Screen.fill_rectangle(x: current_position.column * 16, y: current_position.row * 16, width: 16, height: 16, color: Color.Crimson)
    }
    Screen.draw_number(x: 4, y: 4, value: score, color: Color.Gold, scale: 1)
    Screen.show()
  }
}
```
