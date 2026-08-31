---
id: grid-line
name: Grid.line
category: grid
kind: namespace-method
tokens: Grid.line
sig: Grid.line(x0, y0, x1, y1) -> []Cell
tip: Every cell a straight line from (x0,y0) to (x1,y1) crosses (Bresenham).
order: 1
ns: Grid
member: line
---

Returns the cells a straight line from <code>(x0, y0)</code> to <code>(x1, y1)</code> passes through, endpoints included, using integer Bresenham — the basis of line-of-sight, ray-casting, and drawing on the grid.

Parameters:
- `x0`, `y0` — the start cell
- `x1`, `y1` — the end cell

```ludic
program Demo {
  handler H phase Update {
    let cells = Grid.line(0, 0, 5, 3)
    print(len(cells))
  }
}
```
