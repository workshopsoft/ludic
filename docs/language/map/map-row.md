---
id: map-row
name: Map.row
category: map
kind: namespace-method
tokens: Map.row
sig: Map.row(y, cells)
tip: Fill one row of the tilemap from a string of tile characters.
order: 1
ns: Map
member: row
---

Fills a single map row from a string, one character per cell — an easy, readable way to author a level directly in source. Character <code>y</code> selects the row (from the top, starting at <code>0</code>), and each character of <code>cells</code> becomes the tile at that column. Call <code>Map.size</code> first, then one <code>Map.row</code> per row; the string length should match the map width. By convention <code>'#'</code> is a wall and <code>'.'</code> is open floor, but you may use any characters as your own tile codes and interpret them however you like with <code>Map.tile</code>.

Parameters:
- `y` — the row index to fill, from the top (`0`-based)
- `cells` — a string of tile characters, one per column

```ludic
program HandDrawnLevel {
  const GRID_WIDTH: int = 10
  const GRID_HEIGHT: int = 5
  const TILE_SIZE: int = 16

  handler BuildLevel phase Start {
    Map.size(width: GRID_WIDTH, height: GRID_HEIGHT)
    Map.row(y: 0, cells: "##########")
    Map.row(y: 1, cells: "#........#")
    Map.row(y: 2, cells: "#..####..#")
    Map.row(y: 3, cells: "#........#")
    Map.row(y: 4, cells: "##########")
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
