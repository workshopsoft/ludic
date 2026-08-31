---
id: screen-clip_reset
name: Screen.clip_reset
category: screen
kind: namespace-method
tokens: Screen.clip_reset
sig: Screen.clip_reset()
tip: Lift the clip rectangle (draw to the whole screen again).
order: 20
ns: Screen
member: clip_reset
---

Clears any clip rectangle set by <a href="screen-clip"><code>Screen.clip</code></a>, restoring drawing to the whole framebuffer. Call it once you are done drawing inside a masked region.

```ludic
program Demo {
  handler DrawWorld phase Render {
    Screen.clip(x: 0, y: 0, width: 64, height: 64)
    Screen.circle(x: 32, y: 32, radius: 40, color: Color.Yellow)
    Screen.clip_reset()
    Screen.show()
  }
}
```
