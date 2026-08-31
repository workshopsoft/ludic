---
id: camera-shake
name: Camera.shake
category: camera
kind: namespace-method
tokens: Camera.shake
sig: Camera.shake(amount)
tip: Jitter the camera by up to +/- amount pixels (seeded RNG).
order: 3
ns: Camera
member: shake
---

Adds a random screen shake of up to <code>+/- amount</code> pixels on top of the camera's base offset, drawn from the seeded RNG so a replay shakes identically. Call it each frame with a decaying <code>amount</code> for a hit or explosion; <code>Camera.shake(0)</code> clears it. It stacks on <a href="camera-set"><code>Camera.set</code></a> / <a href="camera-follow"><code>Camera.follow</code></a>, so follow and shake compose.

Parameters:
- `amount` — the maximum shake magnitude in pixels (0 clears it)

```ludic
program Demo {
  property Hit { timer: int = 0 }
  model Cam { Hit }
  handler DrawWorld phase Render {
    if Hit.timer > 0 { Camera.shake(Hit.timer) }
    else { Camera.shake(0) }
    Screen.show()
  }
}
```
