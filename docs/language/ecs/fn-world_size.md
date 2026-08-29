---
id: fn-world_size
name: world_size
category: ecs
kind: builtin
tokens: world_size
sig: world_size() -> int
tip: The number of live model instances in the world.
order: 50
---

<code>world_size</code> returns the total number of live model instances in the world, across every kind, as an `int`. It takes no arguments and is the cheapest way to answer "how big is the world right now?" — useful for a debug readout, a capacity check before a big spawn, or a mod inspecting the running game through the reflection ABI. For a count restricted to instances carrying a particular property, use `world_count` instead.

```ludic
program WorldSize {
  property Position { column: int = 0, row: int = 0 }
  model Enemy { Position }

  handler Boot phase Start {
    spawn GruntA { Position { column: 4, row: 4 } }
    spawn GruntB { Position { column: 6, row: 4 } }
    spawn GruntC { Position { column: 8, row: 4 } }
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    let total = world_size()
    Screen.draw_number(x: 8, y: 8, value: total, color: Color.White, scale: 2)
    Screen.show()
  }
}
```
