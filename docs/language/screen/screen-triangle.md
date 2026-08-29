---
id: screen-triangle
name: Screen.triangle
category: screen
kind: namespace-method
tokens: Screen.triangle
sig: Screen.triangle(x1, y1, x2, y2, x3, y3, color)
tip: Draw a triangle outline.
order: 13
ns: Screen
member: triangle
---

Draws the outline of the triangle with corners <code>(x1, y1)</code>, <code>(x2, y2)</code>, <code>(x3, y3)</code> in <code>color</code> — three lines. Use it for arrows, wedges, and vector shapes.

```ludic
program Demo {
  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    Screen.triangle(x1: 10, y1: 10, x2: 30, y2: 10, x3: 20, y3: 26, color: Color.White)
    Screen.show()
  }
}
```
