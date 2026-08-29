---
id: kw-phase
name: phase
category: structure
kind: keyword
tokens: phase
sig: phase Start | Input | Update | FixedUpdate | Render
tip: Names which stage of the frame a handler runs in.
order: 4
---

Every handler declares a <code>phase</code> — the stage of the frame in which the engine calls it. <b>Start</b> runs once at boot, before the first frame, and is where you seed the world. Then every frame the engine runs, in order, <b>Input</b> (read the keyboard), <b>FixedUpdate</b> (the deterministic fixed-timestep step, for physics and anything that must be reproducible), <b>Update</b> (the ordinary per-frame logic), and <b>Render</b> (draw the frame, ending with `Screen.show()`). Handlers in the same phase run in declaration order, so ordering within a phase is under your control. Put drawing only in `Render`; put keyboard reads in `Input`.

```ludic
program PhaseTour {
  property Position { column: int = 0, row: int = 0 }
  property Velocity { delta_x: int = 0, delta_y: int = 0 }
  model Player { Position, Velocity }

  handler Boot phase Start {
    spawn Hero { Position { column: 5, row: 5 } }
  }

  handler ReadKeys phase Input {
    let pressed = Input.key()
    for (velocity) in query [Velocity, {Player}] {
      if pressed == 'd' { velocity.delta_x = 1 }
      if pressed == 'a' { velocity.delta_x = -1 }
    }
  }

  handler AdvancePositions phase Update {
    for (position, velocity) in query [Position, Velocity, {Player}] {
      position.column = position.column + velocity.delta_x
    }
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    for (position) in query [Position, {Player}] {
      Screen.fill_rectangle(x: position.column * 16, y: position.row * 16, width: 16, height: 16, color: Color.White)
    }
    Screen.show()
  }
}
```
