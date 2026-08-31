---
id: screen-pixel
name: Screen.pixel
category: screen
kind: namespace-method
tokens: Screen.pixel
sig: Screen.pixel(x, y) -> int
tip: Read a framebuffer pixel (0x00RRGGBB), or 0 if off-screen.
order: 23
ns: Screen
member: pixel
---

Reads the colour of the framebuffer pixel at screen <code>(x, y)</code> as <code>0x00RRGGBB</code>, or <code>0</code> if the coordinate is off-screen. Unlike drawing, it ignores the camera — it reports the actual screen. Handy for colour-based collision or hit-testing against what was rendered, and for pixel-exact tests.

```ludic
program Demo {
  handler DrawWorld phase Render {
    Screen.put_pixel(x: 10, y: 10, color: Color.Red)
    if Screen.pixel(10, 10) == Color.Red { Screen.status("hit") }
    Screen.show()
  }
}
```
