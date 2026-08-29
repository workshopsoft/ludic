---
id: list-remove
name: List.remove
category: list
kind: namespace-method
tokens: List.remove
sig: List.remove(s, v) -> void
tip: Remove the first element equal to a value.
order: 12
ns: List
member: remove
---

Scans for the first element equal to <code>v</code> and removes it (shifting the rest down); if no element matches, the slice is unchanged. Comparison is by value for scalars and by identity for reference elements, matching <code>List.contains</code>. Only the first match is removed.

```ludic
program Demo {
  handler Step phase Update {
    List.remove(active, dead_entity)
  }
}
```
