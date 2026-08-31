---
id: camera-follow
name: Camera.follow
category: camera
kind: namespace-method
tokens: Camera.follow
sig: Camera.follow(x, y, lerp)
tip: Ease the camera toward centring a target point.
order: 2
ns: Camera
member: follow
---

Moves the camera a fraction <code>lerp</code> of the way toward centring the world point <code>(x, y)</code> on screen. <code>lerp</code> is a <code>fixed</code> in <code>0.0</code>..<code>1.0</code>: <code>0</code> holds still, a small value trails smoothly behind a moving target, <code>1.0</code> snaps it centred. Call it each frame with the target's position for a classic smooth-follow camera. Deterministic.

Parameters:
- `x`, `y` — the world point to centre on (usually the player)
- `lerp` — how far to move this frame (a `fixed`, 0..1)

```ludic
program Demo {
  property Position { x: int = 0, y: int = 0 }
  model Player { Position }
  handler DrawWorld phase Render {
    Camera.follow(Position.x, Position.y, fixed(1) / fixed(8))   # smooth trail
    Screen.show()
  }
}
```
