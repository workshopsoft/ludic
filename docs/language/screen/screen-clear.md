---
id: screen-clear
name: Screen.clear
category: screen
kind: namespace-method
tokens: Screen.clear
sig: Screen.clear(color)
tip: Fill the whole framebuffer with one color to start a fresh frame.
order: 0
ns: Screen
member: clear
---

Paints every pixel of the framebuffer a single color, wiping whatever the previous frame drew. Call it first inside your <code>Render</code> handler so each frame starts from a known background instead of leftover pixels. The one argument is a color, which can be a named palette value such as <code>Color.MidnightBlue</code> or a raw hex literal like <code>0x0d1020</code>. After clearing, draw the scene on top and finish with <code>Screen.show()</code>.

Parameters:
- `color` — the background color to fill with, e.g. a `Color.*` name or a `0xRRGGBB` literal

```ludic
program ClearBackground {
  var elapsed_frames: int = 0

  handler CountFrames phase Update {
    elapsed_frames = elapsed_frames + 1
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    Screen.draw_number(x: 8, y: 8, value: elapsed_frames, color: Color.White, scale: 1)
    Screen.show()
  }
}
```
