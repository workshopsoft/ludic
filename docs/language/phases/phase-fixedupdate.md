---
id: phase-fixedupdate
name: FixedUpdate
category: phases
kind: phase
tokens: FixedUpdate
sig: phase FixedUpdate
tip: The deterministic simulation step — physics and gameplay meant to be reproducible.
order: 2
---

`FixedUpdate` runs each frame after `Input` and before `Update`. It is the home for the <b>deterministic core of the simulation</b> — movement, collisions, physics — the logic you want to produce the identical result given the same inputs and RNG seed. The runtime groups `Input`, `FixedUpdate`, `Update`, and `LateUpdate` into the "sim" step (exposed together for replay, rollback, and headless tests), while `Render` is kept separate so drawing never affects the outcome. Put anything that must stay reproducible here and mark the handler `@deterministic`; put frame-dressing and non-critical logic in `Update` instead.

```ludic
program FixedUpdateExample {
  property Position { column: int = 0, row: int = 0 }
  property Velocity { delta_x: int = 0, delta_y: int = 0 }
  model Projectile { Position, Velocity }

  handler SpawnShot phase Start {
    spawn Projectile { Position { column: 0, row: 8 };  Velocity { delta_x: 1, delta_y: 0 } }
  }

  @deterministic
  handler AdvancePositions phase FixedUpdate {
    for (current_position, current_velocity) in query [Position, Velocity] {
      current_position.column = current_position.column + current_velocity.delta_x
      current_position.row = current_position.row + current_velocity.delta_y
    }
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    for (current_position) in query [Position, {Projectile}] {
      Screen.fill_rectangle(x: current_position.column * 16, y: current_position.row * 16, width: 16, height: 16, color: Color.Crimson)
    }
    Screen.show()
  }
}
```
