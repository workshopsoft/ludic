---
id: camera-set
name: Camera.set
category: camera
kind: namespace-method
tokens: Camera.set
sig: Camera.set(x, y)
tip: Place the camera at a world-space offset.
order: 1
ns: Camera
member: set
---

Sets the camera offset directly: a world point <code>(wx, wy)</code> draws on screen at <code>(wx - x, wy - y)</code>. The same control as <a href="screen-camera"><code>Screen.camera</code></a>, under the <code>Camera</code> namespace. Use it to snap the view, or as the base that <a href="camera-follow"><code>Camera.follow</code></a> and <a href="camera-shake"><code>Camera.shake</code></a> build on.

```ludic
program Demo {
  property Position { x: int = 0, y: int = 0 }
  model Player { Position }
  handler DrawWorld phase Render {
    Camera.set(Position.x - 160, Position.y - 120)
    Screen.show()
  }
}
```
