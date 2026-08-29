---
id: random-range
name: Random.range
category: random
kind: namespace-method
tokens: Random.range
sig: Random.range(low, high) -> int
tip: A random integer in the inclusive range [low, high].
order: 0
ns: Random
member: range
---

Returns a random integer between <code>low</code> and <code>high</code>, inclusive of both ends — so <code>Random.range(low: 0, high: 3)</code> can return <code>0</code>, <code>1</code>, <code>2</code>, or <code>3</code>. Use it to place things randomly on a grid, pick from a list of options by index, or add jitter to positions and timers. The sequence is deterministic for a given seed, so call <code>Random.seed</code> first if you need reproducible runs. To pick a random <code>column</code> across a grid of width <code>GRID_WIDTH</code>, pass <code>high: GRID_WIDTH - 1</code>, since the last valid index is one less than the count.

Parameters:
- `low` — the smallest value that can be returned (inclusive)
- `high` — the largest value that can be returned (inclusive)

```ludic
program ScatterPickups {
  property Position { column: int = 0, row: int = 0 }
  model Pickup { Position }

  const GRID_WIDTH: int = 20
  const GRID_HEIGHT: int = 15
  const TILE_SIZE: int = 16

  handler SeedPickups phase Start {
    Random.seed(value: 7)
    for spawn_index in 0 .. 5 {
      spawn Pickup {
        Position {
          column: Random.range(low: 0, high: GRID_WIDTH - 1),
          row: Random.range(low: 0, high: GRID_HEIGHT - 1)
        }
      }
    }
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    for (Position) in query [Position, {Pickup}] {
      Screen.fill_rectangle(
        x: Position.column * TILE_SIZE,
        y: Position.row * TILE_SIZE,
        width: TILE_SIZE,
        height: TILE_SIZE,
        color: Color.Gold)
    }
    Screen.show()
  }
}
```
