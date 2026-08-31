---
id: screen-camera
name: Screen.camera
category: screen
kind: namespace-method
tokens: Screen.camera
sig: Screen.camera(x, y)
tip: Set the world-space camera offset for the draw path.
order: 18
ns: Screen
member: camera
---

Sets a camera offset applied to every draw: a world point <code>(wx, wy)</code> lands on screen at <code>(wx - x, wy - y)</code>. Move it to scroll the world under a fixed viewport. The camera moves <em>everything</em> drawn, so reset it to <code>(0, 0)</code> before drawing a fixed HUD. Same control as <a href="camera-set"><code>Camera.set</code></a>. Deterministic.

```ludic
program Demo {
  property Position { x: int = 0, y: int = 0 }
  model Player { Position }
  handler DrawWorld phase Render {
    Screen.camera(Position.x - 160, Position.y - 120)   # centre on the player
    Screen.fill_rectangle(x: 0, y: 0, width: 16, height: 16, color: Color.Red)
    Screen.camera(0, 0)                                  # HUD in screen space
    Screen.draw_text(x: 4, y: 4, text: "SCORE", color: Color.White, scale: 1)
    Screen.show()
  }
}
```
