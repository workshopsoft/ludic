---
id: list-swap
name: List.swap
category: list
kind: namespace-method
tokens: List.swap
sig: List.swap(s, i, j) -> void
tip: Exchange the elements at two indices.
order: 6
ns: List
member: swap
---

Exchanges the elements at indices <code>i</code> and <code>j</code> in <code>s</code>, in place. Both indices must be within the slice. Swapping is the building block of shuffles, sorts, and moving an item to the end before <code>List.pop</code> to remove it cheaply without shifting the rest.

Parameters:
- `s` — the slice to modify
- `i` — the first index
- `j` — the second index

```ludic
program RemoveFast {
  var actors: []int = new []int

  handler Kill phase Update {
    let dead = 2
    let last = List.len(actors) - 1
    List.swap(actors, dead, last)   # move it to the end...
    let removed = List.pop(actors)  # ...then drop it
  }
}
```
