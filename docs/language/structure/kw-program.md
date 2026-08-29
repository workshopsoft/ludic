---
id: kw-program
name: program
category: structure
kind: keyword
tokens: program
sig: program Name { … }
tip: The top-level unit — one program compiles to one native game.
order: 0
---

A <code>program</code> is the outermost unit of Ludic source, and everything else — properties, models, handlers, functions, constants and your named state — lives inside its braces. Each program compiles to exactly one native game (or, with a `module`, one shared library), so a project has a single top-level `program` block. The name you give it is used for the built binary and for diagnostics, and by convention matches the file. When the engine boots, it runs your `Start` handlers once and then drives the per-frame phase loop until the game quits.

```ludic
program SpaceDrift {
  property Position { column: int = 0, row: int = 0 }
  model Player { Position }

  var score: int = 0

  handler Boot phase Start {
    spawn Hero { Position { column: 10, row: 8 } }
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    for (position) in query [Position, {Player}] {
      Screen.fill_rectangle(x: position.column * 16, y: position.row * 16, width: 16, height: 16, color: Color.LimeGreen)
    }
    Screen.draw_number(x: 6, y: 4, value: score, color: Color.Gold, scale: 1)
    Screen.show()
  }
}
```
