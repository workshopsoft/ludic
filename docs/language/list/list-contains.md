---
id: list-contains
name: List.contains
category: list
kind: namespace-method
tokens: List.contains
sig: List.contains(s, v) -> bool
tip: Whether a value appears in a slice.
order: 7
ns: List
member: contains
---

Scans <code>s</code> and returns <code>true</code> if any element equals <code>v</code>. Comparison is by value for scalar elements (ints, entities, booleans) and by identity for reference elements. Use it for membership tests — has this tile been visited, is this entity already in the target list, is the achievement unlocked. It is a linear scan, so for very large or hot-path sets a dedicated structure will be faster.

Parameters:
- `s` — the slice to search
- `v` — the value to look for

```ludic
program Visited {
  state VisitedState {
    seen: []int = new []int
  }

  handler Step(visited_st: VisitedState) phase Update {
    let tile = 42
    if not List.contains(visited_st.seen, tile) {
      List.push(visited_st.seen, tile)
    }
  }
}
```
