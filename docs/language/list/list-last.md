---
id: list-last
name: List.last
category: list
kind: namespace-method
tokens: List.last
sig: List.last(s) -> T
tip: The last element of a slice.
order: 4
ns: List
member: last
---

Returns the final element of <code>s</code> — the value at index <code>List.len(s) - 1</code>. Like <code>List.first</code>, it assumes the slice is non-empty, so guard with a length check when the slice might be empty. Use it to read the most recently pushed item without removing it; use <code>List.pop</code> when you want to take it off.

Parameters:
- `s` — a non-empty slice

```ludic
program Trail {
  state TrailState {
    points: []int = new []int
  }

  handler Head(trail_st: TrailState) phase Update {
    if List.len(trail_st.points) > 0 {
      let newest = List.last(trail_st.points)
    }
  }
}
```
