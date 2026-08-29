---
id: kw-query
name: query
category: ecs
kind: keyword
tokens: query
sig: query [PropA, PropB, {Tag}]
tip: Match every model instance carrying all the listed properties.
order: 2
---

A <code>query</code> selects every live model instance that carries <b>all</b> the listed properties, and is the core way handlers reach data. Use it in a `for (…) in query [...]` loop, where you write one loop variable per bound property in declaration order; each pass binds those properties for one matching instance and `self()` gives that instance. A `{Model}` term in tag position filters by model kind without binding a variable, so `query [Position, {Player}]` walks only players. Add a `where` clause to filter on field values (`where health.current > 0`). Matching is lazy and re-checked per instance as the loop reaches each id, not snapshotted, so spawns and despawns during the loop follow well-defined rules.

```ludic
program Collisions {
  property Position { column: int = 0, row: int = 0 }
  property Health   { current: int = 100, maximum: int = 100 }
  model Enemy { Position, Health }

  handler Boot phase Start {
    spawn Grunt { Position { column: 5, row: 5 }; Health { current: 10 } }
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    for (position, health) in query [Position, Health, {Enemy}] where health.current > 0 {
      Screen.fill_rectangle(x: position.column * 16, y: position.row * 16, width: 16, height: 16, color: Color.Crimson)
    }
    Screen.show()
  }
}
```
