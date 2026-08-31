---
id: grid-blocked
name: Grid.blocked
category: grid
kind: namespace-method
tokens: Grid.blocked
sig: Grid.blocked(x, y, wall) -> bool
tip: True if the cell is out of bounds or holds the wall tile.
order: 2
ns: Grid
member: blocked
---

Whether <code>(x, y)</code> blocks movement — <code>true</code> if it is out of bounds or its tile equals <code>wall</code>. The passability test the other Grid functions share.

Parameters:
- `x`, `y` — the cell
- `wall` — the impassable tile char, e.g. `'#'`

```ludic
program Demo {
  handler H phase Update {
    if Grid.blocked(0, 0, '#') { print(1) }
  }
}
```
