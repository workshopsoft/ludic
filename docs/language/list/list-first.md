---
id: list-first
name: List.first
category: list
kind: namespace-method
tokens: List.first
sig: List.first(s) -> T
tip: The first element of a slice.
order: 3
ns: List
member: first
---

Returns element <code>0</code> of <code>s</code> — the same as <code>s[0]</code>, named for readability. The slice must hold at least one element; calling it on an empty slice reads out of bounds, so guard with <code>List.len(s) > 0</code> when that is possible. Use it to peek at the head of a queue or the front of an ordered list.

Parameters:
- `s` — a non-empty slice

```ludic
program Queue {
  var waiting: []int = new []int

  handler Serve phase Update {
    if List.len(waiting) > 0 {
      let next = List.first(waiting)
    }
  }
}
```
