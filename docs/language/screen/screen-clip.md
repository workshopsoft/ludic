---
id: screen-clip
name: Screen.clip
category: screen
kind: namespace-method
tokens: Screen.clip
sig: Screen.clip(x, y, width, height)
tip: Restrict drawing to a screen-space rectangle.
order: 19
ns: Screen
member: clip
---

Restricts all subsequent drawing to the screen-space rectangle <code>(x, y, width, height)</code> — pixels outside it are discarded. Use it to keep a panel's contents inside its frame, mask a minimap, or draw a wipe transition. Call <a href="screen-clip_reset"><code>Screen.clip_reset</code></a> to lift it. The clip rectangle is in screen space, applied after the camera offset.

```ludic
program Demo {
  handler DrawWorld phase Render {
    Screen.clip(x: 20, y: 20, width: 100, height: 60)
    Screen.fill_rectangle(x: 0, y: 0, width: 320, height: 240, color: Color.Green)
    Screen.clip_reset()
    Screen.show()
  }
}
```
