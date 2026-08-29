---
id: screen-fill_circle
name: Screen.fill_circle
category: screen
kind: namespace-method
tokens: Screen.fill_circle
sig: Screen.fill_circle(x, y, radius, color)
tip: Draw a filled disc.
order: 12
ns: Screen
member: fill_circle
---

Draws a solid disc centred at <code>(x, y)</code> with the given <code>radius</code> in <code>color</code>, one horizontal span per row. Use it for round bodies, bullets, and glows.

```ludic
program Demo {
  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    Screen.fill_circle(x: bx, y: by, radius: 6, color: Color.Gold)
    Screen.show()
  }
}
```
