---
id: kw-in
name: in
category: control
kind: keyword
tokens: in
sig: for x in range | query
tip: The part of a for loop that names what to iterate — a range or a query.
order: 3
---

The <code>in</code> keyword is the bridge in a `for` loop between the loop's bindings and the source it walks. On the right of `in` you write either a numeric range, `a .. b`, binding one fresh index each pass, or an ECS `query [...]`, binding one variable per non-tag property for each matching model instance. It always pairs with `for` and never stands alone. In the query form the parentheses group the bound properties — `for (position, velocity) in query [Position, Velocity]` — and the body then runs once per instance that carries them all.

```ludic
program Movement {
  property Position { column: int = 0, row: int = 0 }
  property Velocity { delta_x: int = 0, delta_y: int = 0 }
  model Enemy { Position, Velocity }

  handler Boot phase Start {
    for slot in 0 .. 3 {
      spawn Grunt { Position { column: slot * 4, row: 2 }; Velocity { delta_x: 1 } }
    }
  }

  handler AdvancePositions phase Update {
    for (position, velocity) in query [Position, Velocity, {Enemy}] {
      position.column = position.column + velocity.delta_x
    }
  }
}
```
