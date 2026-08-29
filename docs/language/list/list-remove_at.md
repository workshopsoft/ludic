---
id: list-remove_at
name: List.remove_at
category: list
kind: namespace-method
tokens: List.remove_at
sig: List.remove_at(s, i) -> void
tip: Remove the element at an index, shifting the rest down.
order: 11
ns: List
member: remove_at
---

Removes the element at index <code>i</code>, moving everything after it one place toward the front and shortening the slice by one. Order is preserved. When order does not matter, swapping the item to the end and calling <code>List.pop</code> is cheaper.

```ludic
program Demo {
  handler Step phase Update {
    List.remove_at(effects, expired)
  }
}
```
