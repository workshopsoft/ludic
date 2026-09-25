---
id: list-reverse
name: List.reverse
category: list
kind: namespace-method
tokens: List.reverse
sig: List.reverse(s) -> void
tip: Reverse the order of a slice in place.
order: 9
ns: List
member: reverse
---

Reverses <code>s</code> so its first element becomes last and vice versa, mutating the slice in place rather than returning a copy. Use it to flip an order you built back-to-front — a path traced from goal to start, an undo stack you want oldest-first, or a list you appended to and now want to read in the opposite direction.

Parameters:
- `s` — the slice to reverse

```ludic
program PathOrder {
  state PathOrderState {
    path: []int = new []int
  }

  handler Finalize(path_order_st: PathOrderState) phase Update {
    # path was built from the goal back to the start
    List.reverse(path_order_st.path)   # now start -> goal
  }
}
```
