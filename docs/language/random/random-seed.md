---
id: random-seed
name: Random.seed
category: random
kind: namespace-method
tokens: Random.seed
sig: Random.seed(value)
tip: Seed the random generator so runs are reproducible.
order: 2
ns: Random
member: seed
---

Sets the starting state of the random-number generator. Every subsequent call to <code>Random.range</code> and <code>Random.chance</code> then follows a fixed, repeatable sequence for that seed, so seeding with the same <code>value</code> makes two runs produce identical randomness — invaluable for tests, replays, and debugging. Seed once, typically in a <code>Start</code>-phase handler before you draw any random numbers. Use different seed values (for example a frame count or a level number) when you want variety between runs.

Parameters:
- `value` — the seed; the same value reproduces the same sequence

```ludic
program ReproducibleField {
  property Position { column: int = 0, row: int = 0 }
  model Star { Position }

  const GRID_WIDTH: int = 20
  const GRID_HEIGHT: int = 15
  const TILE_SIZE: int = 16

  handler SeedField phase Start {
    Random.seed(value: 42)
    for spawn_index in 0 .. 8 {
      spawn Star {
        Position {
          column: Random.range(low: 0, high: GRID_WIDTH - 1),
          row: Random.range(low: 0, high: GRID_HEIGHT - 1)
        }
      }
    }
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    for (Position) in query [Position, {Star}] {
      Screen.fill_rectangle(
        x: Position.column * TILE_SIZE,
        y: Position.row * TILE_SIZE,
        width: TILE_SIZE,
        height: TILE_SIZE,
        color: Color.White)
    }
    Screen.show()
  }
}
```
