---
id: fn-clamp
name: clamp
category: builtins
kind: builtin
tokens: clamp
sig: clamp(v, lo, hi) -> int
tip: Constrain a value to the inclusive range [lo, hi].
order: 9
---

Constrains a value to a range: it returns <code>lo</code> if <code>v</code> is below the range, <code>hi</code> if it is above, and <code>v</code> unchanged when it already lies within <code>[lo, hi]</code>. The classic use is keeping a moving object on screen or inside a grid, so its position can never run past the walls no matter how fast it moves. It saves you writing a pair of <code>if</code> checks by hand. Make sure <code>lo</code> is not greater than <code>hi</code>.

Parameters:
- `v` — the value to constrain
- `lo` — the lowest allowed value (inclusive)
- `hi` — the highest allowed value (inclusive)

```ludic
program ClampToGrid {
  property Position { column: int = 0, row: int = 0 }
  model Player { Position }

  const GRID_WIDTH: int = 20
  const GRID_HEIGHT: int = 15
  const TILE_SIZE: int = 16

  handler SpawnPlayer phase Start {
    spawn Player { Position { column: 5, row: 5 } }
  }

  handler ReadInput phase Input {
    let pressed = Input.key()
    for (Position) in query [Position, {Player}] {
      if pressed == 'd' { Position.column = Position.column + 1 }
      if pressed == 'a' { Position.column = Position.column - 1 }
      Position.column = clamp(Position.column, 0, GRID_WIDTH - 1)
    }
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    for (Position) in query [Position, {Player}] {
      Screen.fill_rectangle(
        x: Position.column * TILE_SIZE,
        y: Position.row * TILE_SIZE,
        width: TILE_SIZE,
        height: TILE_SIZE,
        color: Color.LimeGreen)
    }
    Screen.show()
  }
}
```
