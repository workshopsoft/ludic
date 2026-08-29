---
id: screen-line
name: Screen.line
category: screen
kind: namespace-method
tokens: Screen.line
sig: Screen.line(x1, y1, x2, y2, color)
tip: Draw a straight line between two points.
order: 10
ns: Screen
member: line
---

Draws a one-pixel line from <code>(x1, y1)</code> to <code>(x2, y2)</code> in <code>color</code>, using an integer Bresenham walk so it looks the same on every platform. Use it for lasers, tethers, debug rays, and vector art. Draw during the <code>Render</code> phase.

```ludic
program Demo {
  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    Screen.line(x1: px, y1: py, x2: tx, y2: ty, color: Color.White)
    Screen.show()
  }
}
```
