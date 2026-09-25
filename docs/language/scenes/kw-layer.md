---
id: kw-layer
name: layer
category: scenes
kind: keyword
tokens: layer
sig: layer Name { handlers }
tip: A named group of handlers inside a scene; layers render in declaration order.
order: 1
---

A `layer` groups handlers inside a scene, and <b>declaration order is draw order</b>: within a phase the active scene's layers run in the order they were written, so a `Hud` layer declared after a `World` layer paints its `Render` output on top. Layers are the natural unit for stacking a heads-up display over the play-field, or a menu over a paused world. A layer handler may use any phase except `Start` (boot-time setup belongs in the scene's `on enter`). Handlers that should run in every scene are declared outside any scene rather than in a layer.

```ludic
program LayerExample {
  property Position { column: int = 0, row: int = 0 }
  model Player { Position }

  let score: int = 0

  scene Overworld start {
    on enter { spawn Player { Position { column: 6, row: 6 } } }

    layer World {
      handler DrawWorld phase Render {
        Screen.clear(Color.MidnightBlue)
        for (current_position) in query [Position, {Player}] {
          Screen.fill_rectangle(x: current_position.column * 16, y: current_position.row * 16, width: 16, height: 16, color: Color.LimeGreen)
        }
      }
    }

    layer Hud {
      handler DrawScore phase Render {
        Screen.draw_text(x: 6, y: 4, text: "SCORE", color: Color.White, scale: 1)
        Screen.draw_number(x: 52, y: 4, value: score, color: Color.Gold, scale: 1)
        Screen.show()                     # the last layer to draw presents the frame
      }
    }
  }
}
```
