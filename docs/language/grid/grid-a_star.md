---
id: grid-a_star
name: Grid.a_star
category: grid
kind: namespace-method
tokens: Grid.a_star
sig: Grid.a_star(x0, y0, x1, y1, wall) -> []Cell
tip: The shortest 4-connected path between two cells (A*), or an empty list.
order: 5
ns: Grid
member: a_star
---

Returns the shortest path from <code>(x0, y0)</code> to <code>(x1, y1)</code> over passable (non-<code>wall</code>) cells, 4-connected with uniform step cost, as a <code>Cell</code> slice from start to goal inclusive — an <strong>A*</strong> search with a Manhattan heuristic. Empty if the goal is unreachable (or start/goal is a wall). (Named under <code>Grid</code> rather than <code>Path</code>, which is the filesystem-paths library.)

Parameters:
- `x0`, `y0` — the start cell
- `x1`, `y1` — the goal cell
- `wall` — the impassable tile char, e.g. `'#'`

```ludic
program Demo {
  handler H phase Update {
    let path = Grid.a_star(1, 1, 20, 12, '#')
    if len(path) > 0 { print(len(path)) }
  }
}
```
