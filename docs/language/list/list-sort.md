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

Sorts the elements of <code>s</code> in ascending order in place. It is intended for slices of scalar elements (ints, entities, fixed) where <code>&lt;</code> is meaningful; reference elements are ordered by identity, which is rarely useful. Small lists — the nearly-sorted, per-frame kind games usually hold — take a simple insertion sort; larger lists fall to a stable O(n log n) merge sort. Both are stable, so the result is identical either way. To sort records by a field, or in descending order, or with a custom comparator, use <code>List.sort_by</code>, <code>List.sort_desc_by</code>, or <code>List.sort_with</code>.

```ludic
program Demo {
  handler Step phase Update {
    List.sort(scores)
  }
}
```
