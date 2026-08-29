---
id: screen-put_pixel
name: Screen.put_pixel
category: screen
kind: namespace-method
tokens: Screen.put_pixel
sig: Screen.put_pixel(x, y, color)
tip: Set a single pixel at a pixel coordinate to one color.
order: 3
ns: Screen
member: put_pixel
---

Sets exactly one pixel at <code>(x, y)</code> to the given color — the finest-grained drawing operation Ludic offers. Reach for it when you are plotting individual points such as stars, particles, a scatter of sparks, or hand-drawn curves where a full rectangle would be too coarse. For anything larger than a point prefer <code>Screen.fill_rectangle</code>, since one call per pixel is far more expensive than one call per block. Coordinates are pixels from the top-left of the screen, and out-of-range coordinates are ignored.

Parameters:
- `x` — the pixel column, in pixels from the left of the screen
- `y` — the pixel row, in pixels from the top of the screen
- `color` — the pixel color, e.g. a `Color.*` name or a `0xRRGGBB` literal

```ludic
program Starfield {
  property Position { column: int = 0, row: int = 0 }
  model Star { Position }

  handler SeedStars phase Start {
    Random.seed(value: 1)
    for spawn_index in 0 .. 40 {
      spawn Star {
        Position {
          column: Random.range(low: 0, high: 255),
          row: Random.range(low: 0, high: 223)
        }
      }
    }
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    for (Position) in query [Position, {Star}] {
      Screen.put_pixel(x: Position.column, y: Position.row, color: Color.White)
    }
    Screen.show()
  }
}
```
