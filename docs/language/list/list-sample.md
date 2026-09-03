---
id: list-sample
name: List.sample
category: list
kind: namespace-method
tokens: List.sample
sig: List.sample(pool, count) -> []int
tip: Random picks from an int slice, distinct while it can.
order: 30
ns: List
member: sample
---

Returns <code>count</code> picks from an <code>[]int</code>, drawn from the seeded RNG. Picks are distinct while the pool has enough elements; with fewer, the spare picks repeat a valid element. An empty pool yields zeros. A relic offer, a loot roll, a random enemy roster.

```ludic
# doc-check: skip — illustrative
relic_offer = List.sample(Relics.unowned(), 3)
```
