---
id: annot-queries
name: @Queries
category: annotations
kind: annotation
tokens: @Queries
sig: @Queries(these: [Position, Velocity])
tip: Declare the properties a handler operates on, binding their fields by name in the body.
order: 0
---

<code>@Queries</code> lets a handler declare the properties it operates on up front, and the compiler wraps the whole body in a query loop over the matching model instances. The body then runs once per match with each listed property bound by name — you write <code>Position.column</code> directly instead of opening a <code>for (…) in query […]</code> yourself — and <code>self()</code> gives the current instance. It takes the same shape as a manual query: <code>these: [ … ]</code> lists the required properties (each may carry a filter like <code>Health{current &lt;= 0}</code>), and an optional <code>on: Model</code> restricts the match to instances of one model. Reach for it when a handler's entire job is "for every matching instance, do this"; drop to an explicit <code>query</code> when you need finer control inside the loop.

```ludic
program AdvanceMovement {
  property Position { column: int = 0, row: int = 0 }
  property Velocity { delta_x: int = 0, delta_y: int = 0 }
  model Player { Position, Velocity }

  @Queries(these: [Position, Velocity], on: Player)   # body runs once per matching Player
  handler AdvancePositions phase FixedUpdate {
    Position.column = Position.column + Velocity.delta_x
    Position.row = Position.row + Velocity.delta_y
  }

  handler SpawnPlayer phase Start {
    spawn Player { Position { column: 0, row: 0 }, Velocity { delta_x: 1, delta_y: 0 } }
  }
}
```
