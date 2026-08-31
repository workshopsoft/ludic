---
id: grid-flood
name: Grid.flood
category: grid
kind: namespace-method
tokens: Grid.flood
sig: Grid.flood(x, y, wall) -> []Cell
tip: Every passable cell reachable from (x,y), 4-connected, in BFS order.
order: 4
ns: Grid
member: flood
---

Returns every passable cell reachable from <code>(x, y)</code> by 4-connected steps (up/down/left/right over non-<code>wall</code> cells), in breadth-first order — for connectivity checks, filling a room, or measuring an enclosed area. Empty if the start itself is blocked.

Parameters:
- `x`, `y` — the seed cell
- `wall` — the impassable tile char

```ludic
program Demo {
  handler H phase Update {
    let region = Grid.flood(2, 2, '#')
    print(len(region))
  }
}
```
