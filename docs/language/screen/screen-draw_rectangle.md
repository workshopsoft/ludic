---
id: screen-draw_rectangle
name: Screen.draw_rectangle
category: screen
kind: namespace-method
tokens: Screen.draw_rectangle
sig: Screen.draw_rectangle(x, y, width, height, color)
tip: Draw a one-pixel-thick rectangle outline (not filled).
order: 2
ns: Screen
member: draw_rectangle
---

Draws just the border of a rectangle — a one-pixel-thick outline — leaving the interior untouched so whatever is behind it shows through. It takes the same top-left position and size as <code>Screen.fill_rectangle</code>, but is meant for framing rather than filling: selection boxes, UI panels, health-bar borders, or highlighting the tile under a cursor. Use it together with <code>fill_rectangle</code> when you want a filled shape with a contrasting edge. Coordinates are in pixels from the top-left of the screen.

Parameters:
- `x` — the left edge, in pixels from the left of the screen
- `y` — the top edge, in pixels from the top of the screen
- `width` — the outline width in pixels
- `height` — the outline height in pixels
- `color` — the outline color, e.g. a `Color.*` name or a `0xRRGGBB` literal

```ludic
program SelectionFrame {
  property Position { column: int = 0, row: int = 0 }
  model Enemy { Position }

  const TILE_SIZE: int = 16

  handler SpawnEnemy phase Start {
    spawn Enemy { Position { column: 6, row: 5 } }
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    for (Position) in query [Position, {Enemy}] {
      let pixel_x = Position.column * TILE_SIZE
      let pixel_y = Position.row * TILE_SIZE
      Screen.fill_rectangle(x: pixel_x, y: pixel_y, width: TILE_SIZE, height: TILE_SIZE, color: Color.Crimson)
      Screen.draw_rectangle(x: pixel_x, y: pixel_y, width: TILE_SIZE, height: TILE_SIZE, color: Color.Gold)
    }
    Screen.show()
  }
}
```
