---
id: noise-cellular2_id
name: Noise.cellular2_id
category: noise
kind: namespace-method
tokens: Noise.cellular2_id
sig: Noise.cellular2_id(x, y, seed) -> int
tip: The id of the nearest Worley cell — stable per cell.
order: 6
ns: Noise
member: cellular2_id
---

Returns the integer **id of the nearest cell** in the same Worley diagram that <a href="noise-cellular2"><code>Noise.cellular2</code></a> measures distance in — a stable hash that is identical for every sample point inside a given cell. Use it to assign something discrete per region: the biome or material of a cell, the variant of a scattered prop, a per-region colour. Combine it with the F1 distance to shade toward cell edges.

The id is a hash, so treat it as an opaque label (mod it into your table of choices); it is deterministic across platforms and runs.

Parameters:
- `x`, `y` — the sample coordinates (`fixed`)
- `seed` — the field selector (must match the `cellular2` call it pairs with)

```ludic
program CellId {
  entry {
    let seed = 7
    let id = Noise.cellular2_id(fixed(5) / fixed(4), fixed(3) / fixed(4), seed)
    let biome = Math.posmod(id, 4)   # one of 4 biomes for this cell
    print(biome)
  }
}
```
