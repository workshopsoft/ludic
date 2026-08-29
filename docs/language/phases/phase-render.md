---
id: phase-render
name: Render
category: phases
kind: phase
tokens: Render
sig: phase Render
tip: The last per-frame phase — draw the world, then call Screen.show() once.
order: 5
---

`Render` is the final phase of every frame, run after all the logic phases (`Input`, `FixedUpdate`, `Update`, `LateUpdate`) have finished. A `handler … phase Render` paints the frame with the `Screen.*` calls — start by clearing the surface with `Screen.clear`, draw everything back-to-front, and finish with a single `Screen.show()` to present the completed frame to the window. Keep `Render` free of game-state changes: it should read the world and draw it, not move things, so that the drawing never affects the simulation. When you use scenes, layers within a scene render in declaration order, so a HUD layer written after a world layer paints on top of it.

```ludic
program RenderExample {
  property Position { column: int = 0, row: int = 0 }
  model Player { Position }

  const TILE_SIZE: int = 16
  var score: int = 0

  handler PlacePlayer phase Start {
    spawn Player { Position { column: 5, row: 6 } }
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    for (current_position) in query [Position, {Player}] {
      Screen.fill_rectangle(
        x: current_position.column * TILE_SIZE,
        y: current_position.row * TILE_SIZE,
        width: TILE_SIZE, height: TILE_SIZE, color: Color.LimeGreen)
    }
    Screen.draw_text(x: 6, y: 4, text: "SCORE", color: Color.White, scale: 1)
    Screen.draw_number(x: 52, y: 4, value: score, color: Color.Gold, scale: 1)
    Screen.show()
  }
}
```
