---
id: list-sort_with
name: List.sort_with
category: list
kind: namespace-method
tokens: List.sort_with
sig: List.sort_with(s, cmp) -> void
tip: Sort a slice with a full two-argument comparator.
order: 16
ns: List
member: sort_with
---

Sorts <code>s</code> in place with a full comparator <code>cmp(a, b) -> int</code>: return a negative number when <code>a</code> should come before <code>b</code>, positive when after, and zero when they tie. Reach for this when the order is not a single key — a multi-field sort (by rarity, then by name), or a comparison that mixes fields. For the common "subtract two numbers" comparator, returning <code>a.field - b.field</code> gives ascending order. The sort is <strong>stable</strong> (O(n log n) merge sort), so ties (a zero result) keep the elements' prior order.

```ludic
# doc-check: skip — illustrative; `cmp` is any fn(a, b) -> int in scope
function by_price(a: Item, b: Item) -> int { return a.price - b.price }

program Demo {
  handler Step phase Update {
    List.sort_with(shop, by_price)   # cheapest first
  }
}
```
