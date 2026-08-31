---
id: grid-line_of_sight
name: Grid.line_of_sight
category: grid
kind: namespace-method
tokens: Grid.line_of_sight
sig: Grid.line_of_sight(x0, y0, x1, y1, wall) -> bool
tip: True if the straight line between two cells crosses no wall.
order: 3
ns: Grid
member: line_of_sight
---

Whether an unobstructed straight line connects <code>(x0, y0)</code> and <code>(x1, y1)</code> — <code>true</code> when no cell it crosses (endpoints included) is a <code>wall</code>. Use it for visibility, aggro checks, and cover.

Parameters:
- `x0`, `y0` — the viewer cell
- `x1`, `y1` — the target cell
- `wall` — the impassable tile char

```ludic
program Demo {
  handler H phase Update {
    if Grid.line_of_sight(1, 1, 8, 1, '#') { print(1) }
  }
}
```
