---
id: list-index_of
name: List.index_of
category: list
kind: namespace-method
tokens: List.index_of
sig: List.index_of(s, v) -> int
tip: The index of a value in a slice, or -1 if absent.
order: 8
ns: List
member: index_of
---

Scans <code>s</code> and returns the index of the first element equal to <code>v</code>, or <code>-1</code> if none match. It uses the same value/identity comparison as <code>List.contains</code>, but tells you where the match is so you can act on it — swap it out, read a parallel slice at the same index, or guard with <code>if idx >= 0</code>. Only the first match is reported.

Parameters:
- `s` — the slice to search
- `v` — the value to locate

```ludic
program FindSlot {
  var ids: []int = new []int

  handler Locate phase Update {
    let slot = List.index_of(ids, 99)
    if slot >= 0 {
      List.swap(ids, slot, List.len(ids) - 1)
    }
  }
}
```
