---
id: kw-property
name: property
category: structure
kind: keyword
tokens: property
sig: property Name { field: T = default, … }
tip: A named record of typed fields — a per-model component, or a plain heap record.
order: 1
---

A <code>property</code> declares a named record of typed fields, each with a default value. It is the one record keyword in Ludic, and how you <b>use</b> it decides how it is stored: list it in a `model` (or `attach` it with `spawn`) and it becomes a per-instance component held in the engine's storage and bound in queries; construct it with `new` and it becomes a plain heap record addressed by a pointer. Fields carry a type and a default, so a freshly spawned or `new`-ed property starts fully seeded. Give fields descriptive names — `column`/`row`, not `x`/`y` — because those names are what handlers read and write.

```ludic
program Descent {
  property Position { column: int = 0, row: int = 0 }
  property Health   { current: int = 100, maximum: int = 100 }
  model Player { Position, Health }

  handler Spawn phase Start {
    spawn Hero { Position { column: 4, row: 4 }; Health { current: 80 } }
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    for (position, health) in query [Position, Health, {Player}] {
      let bar_width = health.current / 4
      Screen.fill_rectangle(x: position.column, y: position.row, width: bar_width, height: 4, color: Color.Crimson)
    }
    Screen.show()
  }
}
```
