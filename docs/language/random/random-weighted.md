---
id: random-weighted
name: Random.weighted
category: random
kind: namespace-method
tokens: Random.weighted
sig: Random.weighted(weights: []int) -> int
tip: An index drawn in proportion to its weight.
order: 10
ns: Random
member: weighted
---

Picks an index into `weights` with probability proportional to the weight (a weight of 0 is never picked); -1 when every weight is 0. Deterministic, from the seeded RNG. A loot table, a spawn roster, a random event.

```ludic
# doc-check: skip — illustrative
let pick = roster[Random.weighted(weights: weights)]
```
