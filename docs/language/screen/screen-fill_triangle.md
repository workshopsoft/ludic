---
id: screen-fill_triangle
name: Screen.fill_triangle
category: screen
kind: namespace-method
tokens: Screen.fill_triangle
sig: Screen.fill_triangle(x1, y1, x2, y2, x3, y3, color)
tip: Draw a filled triangle.
order: 14
ns: Screen
member: fill_triangle
---

Fills the triangle with corners <code>(x1, y1)</code>, <code>(x2, y2)</code>, <code>(x3, y3)</code> in <code>color</code>, scanning its bounding box with an inside test. The building block for flat-shaded polygons and arrowheads.

```ludic
program Demo {
  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    Screen.fill_triangle(x1: 10, y1: 10, x2: 30, y2: 10, x3: 20, y3: 26, color: Color.Red)
    Screen.show()
  }
}
```
