---
id: kw-model
name: model
category: structure
kind: keyword
tokens: model
sig: model Name { PropA, PropB, … }
tip: A named kind of thing — a fixed bundle of properties you spawn by one name.
order: 2
---

A <code>model</code> names a <b>kind</b> of thing in your game and the fixed set of properties every instance of it carries. Instead of attaching properties one by one, you `spawn` the model by name and every listed property comes with it, seeded from its defaults. A model's name doubles as a query tag: write `{Player}` inside a `query [...]` to match only instances of that model. The model itself has no fields of its own, so you never bind it to a variable — you bind its properties and filter by its tag.

```ludic
program Arena {
  property Position { column: int = 0, row: int = 0 }
  property Velocity { delta_x: int = 0, delta_y: int = 0 }
  property Health   { current: int = 100, maximum: int = 100 }

  model Player { Position, Health }
  model Enemy  { Position, Velocity, Health }

  handler Spawn phase Start {
    spawn Hero  { Position { column: 2, row: 8 } }
    spawn Grunt { Position { column: 18, row: 8 }; Velocity { delta_x: -1 } }
  }

  handler AdvanceEnemies phase Update {
    for (position, velocity) in query [Position, Velocity, {Enemy}] {
      position.column = position.column + velocity.delta_x
    }
  }
}
```
