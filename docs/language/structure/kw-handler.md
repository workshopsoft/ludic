---
id: kw-handler
name: handler
category: structure
kind: keyword
tokens: handler
sig: handler Name phase P { … }
tip: A named block the engine runs each frame during phase P.
order: 3
---

A <code>handler</code> is a named block of behavior that the engine runs automatically during a given `phase` — the unit that turns your data into a game. A handler with no query runs <b>once per phase tick</b>; a handler with a `@Queries` annotation (or an inline `for (…) in query […]` loop) runs its body <b>once per matching model instance</b>, with each property bound by name and `self()` giving the current instance. Handlers are registered implicitly just by being declared, and you can pause one at runtime with `disable Handler` and bring it back with `enable Handler`. Keep behavior in handlers and keep data plain in properties — that separation is the whole point.

```ludic
program Runner {
  property Position { column: int = 0, row: int = 0 }
  property Velocity { delta_x: int = 0, delta_y: int = 0 }
  model Player { Position, Velocity }

  handler Boot phase Start {
    spawn Hero { Position { column: 0, row: 6 }; Velocity { delta_x: 1 } }
  }

  handler AdvancePositions phase Update {
    for (position, velocity) in query [Position, Velocity, {Player}] {
      position.column = position.column + velocity.delta_x
    }
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    for (position) in query [Position, {Player}] {
      Screen.fill_rectangle(x: position.column * 16, y: position.row * 16, width: 16, height: 16, color: Color.LimeGreen)
    }
    Screen.show()
  }
}
```
