---
id: map-size
name: Map.size
category: map
kind: namespace-method
tokens: Map.size
sig: Map.size(width, height)
tip: Set the tilemap dimensions in cells before filling rows.
order: 0
ns: Map
member: size
---

Declares the dimensions of the built-in tilemap, in cells (not pixels). Call it once during a <code>Start</code>-phase handler before you fill the map with <code>Map.row</code>, so the runtime knows how many columns and rows to allocate. The tilemap is a lightweight, character-based grid the whole program can read with <code>Map.tile</code>, which is handy for static level geometry such as walls and floors. Reads outside these bounds are treated as a wall character, so the edge of the world is solid for free.

Parameters:
- `width` — the map width in cells (columns)
- `height` — the map height in cells (rows)

```ludic
program LevelBounds {
  const GRID_WIDTH: int = 12
  const GRID_HEIGHT: int = 4
  const TILE_SIZE: int = 16

  handler BuildLevel phase Start {
    Map.size(width: GRID_WIDTH, height: GRID_HEIGHT)
    Map.row(y: 0, cells: "############")
    Map.row(y: 1, cells: "#..........#")
    Map.row(y: 2, cells: "#..........#")
    Map.row(y: 3, cells: "############")
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    for row in 0 .. GRID_HEIGHT {
      for column in 0 .. GRID_WIDTH {
        if Map.tile(x: column, y: row) == '#' {
          Screen.fill_rectangle(
            x: column * TILE_SIZE,
            y: row * TILE_SIZE,
            width: TILE_SIZE,
            height: TILE_SIZE,
            color: Color.White)
        }
      }
    }
    Screen.show()
  }
}
```
