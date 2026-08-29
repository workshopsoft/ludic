---
id: list-len
name: List.len
category: list
kind: namespace-method
tokens: List.len
sig: List.len(s) -> int
tip: The number of elements in a slice.
order: 0
ns: List
member: len
---

Returns how many elements <code>s</code> currently holds. It reads the slice's length, which changes as you <code>List.push</code> and <code>List.pop</code>, and is the same value as the bare <code>len(s)</code>. Use it to bound a loop, test for emptiness, or find the last index with <code>List.len(s) - 1</code>.

Parameters:
- `s` — the slice to measure

```ludic
program CountEnemies {
  var enemies: []int = new []int

  handler Report phase Update {
    let n = List.len(enemies)
  }
}
```
