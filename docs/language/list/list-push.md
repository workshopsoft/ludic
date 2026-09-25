---
id: list-push
name: List.push
category: list
kind: namespace-method
tokens: List.push
sig: List.push(s, v) -> void
tip: Append an element to the end of a slice.
order: 1
ns: List
member: push
---

Adds <code>v</code> to the end of <code>s</code>, growing the backing buffer if needed, so the slice's length increases by one. It is the same operation as the bare <code>push(s, v)</code>. Because a slice is shared, the new element is visible to every holder. Use it to collect spawned entities, build a list of hits, or fill an inventory.

Parameters:
- `s` — the slice to append to
- `v` — the element to add (matching the slice's element type)

```ludic
program Collect {
  state CollectState {
    picked: []int = new []int
  }

  handler Grab(collect_st: CollectState) phase Update {
    List.push(collect_st.picked, 7)
  }
}
```
