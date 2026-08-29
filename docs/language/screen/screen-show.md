---
id: screen-show
name: Screen.show
category: screen
kind: namespace-method
tokens: Screen.show
sig: Screen.show()
tip: Present the finished frame — copy everything drawn this frame to the window.
order: 6
ns: Screen
member: show
---

Presents the frame: it copies everything you have drawn into the framebuffer this pass onto the visible window all at once. Call it exactly once, as the very last statement of your <code>Render</code> handler, after every <code>Screen.clear</code>, <code>fill_rectangle</code>, <code>draw_text</code>, and other draw call. Because drawing happens off-screen and only <code>show</code> makes it visible, the player never sees a half-drawn frame (no flicker or tearing). Forgetting to call it means your drawing never appears; it takes no arguments.

```ludic
program PresentFrame {
  property Position { column: int = 0, row: int = 0 }
  model Player { Position }

  const TILE_SIZE: int = 16

  handler SpawnPlayer phase Start {
    spawn Player { Position { column: 5, row: 5 } }
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
