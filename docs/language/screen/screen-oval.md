---
id: screen-oval
name: Screen.oval
category: screen
kind: namespace-method
tokens: Screen.oval
sig: Screen.oval(x, y, rx, ry, color)
tip: Draw an axis-aligned ellipse outline.
order: 17
ns: Screen
member: oval
---

Draws the outline of an ellipse centred at <code>(x, y)</code> with horizontal radius <code>rx</code> and vertical radius <code>ry</code>, in <code>color</code>, by the integer midpoint algorithm. Equal radii draw a circle; use it for eyes, planets, health auras, and selection ovals.

```ludic
program Demo {
  handler DrawWorld phase Render {
    Screen.clear(Color.Black)
    Screen.oval(x: 160, y: 120, rx: 60, ry: 30, color: Color.Cyan)
    Screen.show()
  }
}
```
