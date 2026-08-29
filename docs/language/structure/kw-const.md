---
id: kw-const
name: const
category: structure
kind: keyword
tokens: const
sig: const NAME: T = value
tip: A compile-time constant, folded into the code with no storage.
order: 5
---

A <code>const</code> binds a name to a value known at compile time. Unlike `var`, it has no storage and cannot be reassigned — the compiler folds it directly into wherever it is used, so it costs nothing at runtime. Reach for `const` for the fixed dimensions and magic numbers of your game — grid sizes, tile pixels, tuning values — so the code reads in names instead of literals. Give constants descriptive, uppercase names, and use them everywhere the value appears so a single edit changes the whole game.

```ludic
program Board {
  const GRID_WIDTH: int = 20
  const GRID_HEIGHT: int = 15
  const TILE_SIZE: int = 16

  property Position { column: int = 0, row: int = 0 }
  model Player { Position }

  handler Boot phase Start {
    spawn Hero { Position { column: GRID_WIDTH / 2, row: GRID_HEIGHT / 2 } }
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    for (position) in query [Position, {Player}] {
      Screen.fill_rectangle(x: position.column * TILE_SIZE, y: position.row * TILE_SIZE, width: TILE_SIZE, height: TILE_SIZE, color: Color.Gold)
    }
    Screen.show()
  }
}
```
