---
id: screen-height
name: Screen.height
category: screen
kind: namespace-method
tokens: Screen.height
sig: Screen.height() -> int
tip: The framebuffer height in pixels.
order: 8
ns: Screen
member: height
---

Returns the height of the framebuffer in pixels — the number of drawable rows. Use it, together with <code>Screen.width</code>, to position elements relative to the bottom or vertical center of the screen instead of assuming a fixed size. A common use is keeping a moving object on screen by clamping its pixel row against this value. It takes no arguments and can be read during any handler.

```ludic
program GroundLine {
  property Position { column: int = 0, row: int = 0 }
  model Player { Position }

  const TILE_SIZE: int = 16

  handler SpawnPlayer phase Start {
    spawn Player { Position { column: 3, row: 0 } }
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    let ground_y = Screen.height() - TILE_SIZE
    for (Position) in query [Position, {Player}] {
      Screen.fill_rectangle(
        x: Position.column * TILE_SIZE,
        y: ground_y,
        width: TILE_SIZE,
        height: TILE_SIZE,
        color: Color.LimeGreen)
    }
    Screen.show()
  }
}
```
