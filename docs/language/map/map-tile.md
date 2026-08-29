---
id: map-tile
name: Map.tile
category: map
kind: namespace-method
tokens: Map.tile
sig: Map.tile(x, y) -> int
tip: Read the tile character at a cell (out-of-bounds reads answer '#').
order: 2
ns: Map
member: tile
---

Reads the tile character at cell <code>(x, y)</code> and returns it as a character code, so you can compare it against literals like <code>'#'</code> or <code>'.'</code>. Use it for collision checks (is the cell ahead a wall?), rendering the map, or querying your own custom tile codes. Cells outside the map you set with <code>Map.size</code> answer <code>'#'</code>, so the border of the world acts as a wall automatically and you never need special edge-of-map handling. Coordinates are cell indices, not pixels.

Parameters:
- `x` — the cell column to read (`0`-based)
- `y` — the cell row to read (`0`-based)

```ludic
program WallCollision {
  property Position { column: int = 0, row: int = 0 }
  model Player { Position }

  const TILE_SIZE: int = 16

  handler BuildLevel phase Start {
    Map.size(width: 8, height: 4)
    Map.row(y: 0, cells: "########")
    Map.row(y: 1, cells: "#..##..#")
    Map.row(y: 2, cells: "#......#")
    Map.row(y: 3, cells: "########")
    spawn Player { Position { column: 1, row: 2 } }
  }

  handler MovePlayer phase Update {
    for (Position) in query [Position, {Player}] {
      let next_column = Position.column + 1
      if Map.tile(x: next_column, y: Position.row) != '#' {
        Position.column = next_column
      }
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
