---
id: list-sort_by
name: List.sort_by
category: list
kind: namespace-method
tokens: List.sort_by
sig: List.sort_by(s, key) -> void
tip: Sort a slice ascending by a key each element maps to.
order: 14
ns: List
member: sort_by
---

Sorts <code>s</code> in place, ascending, by the number each element maps to through <code>key</code> — a function taking one element and returning an <code>int</code>, <code>fixed</code>, or <code>long</code>. This is how you sort records and entities rather than bare scalars: draw order by <code>y</code>, an inventory by price, nearest targets by distance. The sort is <strong>stable</strong> (O(n log n) merge sort), so elements with equal keys keep the order they already had — the tie-break that keeps sprites from flickering when their <code>y</code> matches.

```ludic
# doc-check: skip — illustrative; `key` is any fn(element) -> number in scope
function draw_key(e: Sprite) -> int { return e.y }

program Demo {
  handler Step phase Update {
    List.sort_by(sprites, draw_key)   # back-to-front draw order
  }
}
```
