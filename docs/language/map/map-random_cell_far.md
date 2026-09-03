---
id: map-random_cell_far
name: Map.random_cell_far
category: map
kind: namespace-method
tokens: Map.random_cell_far
sig: Map.random_cell_far(glyph:, from:, min_tiles:) -> IVec2
tip: A random cell with the glyph, at least a distance from a point.
order: 20
ns: Map
member: random_cell_far
---

Like <code>Map.random_cell</code>, but at least <code>min_tiles</code> from <code>from</code> when it can find one — a spawn point away from the hero.

```ludic
# doc-check: skip — illustrative
let tile = Map.random_cell_far(glyph: '.', from: hero_tile, min_tiles: 6)
```
