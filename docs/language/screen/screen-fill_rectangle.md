---
id: screen-fill_rectangle
name: Screen.fill_rectangle
category: screen
kind: namespace-method
tokens: Screen.fill_rectangle
sig: Screen.fill_rectangle(x, y, width, height, color)
tip: Draw a solid, filled rectangle at a pixel position.
order: 1
ns: Screen
member: fill_rectangle
---

Draws a solid block of color from the top-left corner <code>(x, y)</code> spanning <code>width</code> by <code>height</code> pixels. This is the workhorse for drawing tiles, sprites-from-primitives, health bars, and background panels, since a Ludic game paints every pixel itself rather than loading image assets. Coordinates are in pixels measured from the top-left of the screen, so multiply a grid <code>column</code>/<code>row</code> by your tile size to place things on a board. Parts of the rectangle that fall outside the framebuffer are simply clipped.

Parameters:
- `x` — the left edge, in pixels from the left of the screen
- `y` — the top edge, in pixels from the top of the screen
- `width` — the rectangle width in pixels
- `height` — the rectangle height in pixels
- `color` — the fill color, e.g. a `Color.*` name or a `0xRRGGBB` literal

```ludic
program FilledTiles {
  property Position { column: int = 0, row: int = 0 }
  model Player { Position }

  const TILE_SIZE: int = 16

  handler SpawnPlayer phase Start {
    spawn Player { Position { column: 4, row: 3 } }
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
