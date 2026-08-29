---
id: list-sort
name: List.sort
category: list
kind: namespace-method
tokens: List.sort
sig: List.sort(s) -> void
tip: Sort a slice in ascending order, in place.
order: 13
ns: List
member: sort
---

Sorts the elements of <code>s</code> in ascending order in place, using an insertion sort. It is intended for slices of scalar elements (ints, entities, fixed) where <code>&lt;</code> is meaningful; reference elements are ordered by identity, which is rarely useful. Insertion sort is simple and fast for the small, nearly-sorted lists games usually hold.

```ludic
program Demo {
  handler Step phase Update {
    List.sort(scores)
  }
}
```
