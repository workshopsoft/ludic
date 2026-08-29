---
id: random-chance
name: Random.chance
category: random
kind: namespace-method
tokens: Random.chance
sig: Random.chance(percent) -> bool
tip: Return true with the given percent probability.
order: 1
ns: Random
member: chance
---

Returns <code>true</code> roughly <code>percent</code> times out of a hundred, and <code>false</code> otherwise — a convenient shorthand for "this happens X% of the time". Use it to gate random events such as spawning an enemy on a given frame, dropping loot, or triggering a rare animation. Passing <code>0</code> never fires and <code>100</code> always fires. Like the rest of the <code>Random</code> namespace it is driven by the seeded generator, so seed it with <code>Random.seed</code> for reproducible behavior.

Parameters:
- `percent` — the probability of returning `true`, from `0` to `100`

```ludic
program SpawnWave {
  property Position { column: int = 0, row: int = 0 }
  model Enemy { Position }

  const GRID_WIDTH: int = 20
  const TILE_SIZE: int = 16

  handler SeedRandom phase Start {
    Random.seed(value: 3)
  }

  handler MaybeSpawn phase Update {
    if Random.chance(percent: 10) {
      spawn Enemy {
        Position { column: Random.range(low: 0, high: GRID_WIDTH - 1), row: 0 }
      }
    }
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    for (Position) in query [Position, {Enemy}] {
      Screen.fill_rectangle(
        x: Position.column * TILE_SIZE,
        y: Position.row * TILE_SIZE,
        width: TILE_SIZE,
        height: TILE_SIZE,
        color: Color.Crimson)
    }
    Screen.show()
  }
}
```
