---
id: phase-overlay
name: Overlay
category: phases
kind: phase
tokens: Overlay
sig: phase Overlay
tip: The HUD pass — runs after Render and after every engine-owned drawing system.
order: 6
---

`Overlay` runs after `Render` and after every engine-owned drawing system (sprites, lights, the scene's `shows` menu), so a `handler … phase Overlay` paints on top of the finished world: health bars, score, prompts, a boss bar. With `@ClearColor` the engine owns the clear and the present, so an `Overlay` handler only draws — no `Screen.clear`, no `Screen.show`. Like `Render`, it should read the world and never change it.

```ludic
program OverlayExample {
  property Position { column: int = 0, row: int = 0 }
  model Player { Position }

  const TILE_SIZE: int = 16
  var score: int = 0

  handler PlacePlayer phase Start {
    spawn Player { Position { column: 5, row: 6 } }
  }

  @ClearColor(Color.MidnightBlue)
  handler DrawWorld phase Render {
    for (current_position) in query [Position, {Player}] {
      Screen.fill_rectangle(
        x: current_position.column * TILE_SIZE,
        y: current_position.row * TILE_SIZE,
        width: TILE_SIZE, height: TILE_SIZE, color: Color.LimeGreen)
    }
  }

  handler DrawHud phase Overlay {
    Screen.draw_text(x: 6, y: 4, text: "SCORE", color: Color.White, scale: 1)
    Screen.draw_number(x: 52, y: 4, value: score, color: Color.Gold, scale: 1)
  }
}
```
