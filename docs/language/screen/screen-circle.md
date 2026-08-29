---
id: screen-circle
name: Screen.circle
category: screen
kind: namespace-method
tokens: Screen.circle
sig: Screen.circle(x, y, radius, color)
tip: Draw a circle outline.
order: 11
ns: Screen
member: circle
---

Draws the outline of a circle centred at <code>(x, y)</code> with the given <code>radius</code> in <code>color</code>. Use it for rings, radii, and selection markers; for a solid disc use <code>Screen.fill_circle</code>.

```ludic
program Demo {
  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    Screen.circle(x: 160, y: 120, radius: 40, color: Color.Cyan)
    Screen.show()
  }
}
```
