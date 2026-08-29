---
id: fn-world_count
name: world_count
category: ecs
kind: builtin
tokens: world_count
sig: world_count() -> int
tip: The total number of live model instances in the world.
order: 50
---

<code>world_count</code> returns the total number of live model instances in the world, as an `int` — a quick census without walking the world yourself. It takes no arguments and counts every spawned instance regardless of which properties it carries, so it is handy for a mod or debug overlay that wants a running tally of everything alive using the reflection ABI rather than a `query` loop. To resolve names to numeric ids for the other reflection calls, see `world_prop_id`; to read a specific instance's fields by id, see `world_get`.

```ludic
program Census {
  property Position { column: int = 0, row: int = 0 }
  model Enemy { Position }

  handler SpawnEnemies phase Start {
    spawn Enemy { Position { column: 3, row: 3 } }
    spawn Enemy { Position { column: 9, row: 3 } }
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    let alive = world_count()
    Screen.draw_number(x: 8, y: 8, value: alive, color: Color.Gold, scale: 2)
    Screen.show()
  }
}
```
