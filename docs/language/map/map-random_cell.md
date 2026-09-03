---
id: map-random_cell
name: Map.random_cell
category: map
kind: namespace-method
tokens: Map.random_cell
sig: Map.random_cell(glyph: g) -> IVec2
tip: A random cell holding the glyph (seeded RNG).
order: 15
ns: Map
member: random_cell
---

Picks a random cell whose glyph matches: random tries first, then a sweep, so a map with any such cell always yields one; <code>(-1, -1)</code> when none exists. Deterministic, from the seeded RNG.

```ludic
# doc-check: skip — illustrative
let tile = Map.random_cell(glyph: '.')
Spawn.enemy(kind, IVec2.scale(tile, 16))
```
