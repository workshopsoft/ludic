---
id: noise-cellular2
name: Noise.cellular2
category: noise
kind: namespace-method
tokens: Noise.cellular2
sig: Noise.cellular2(x, y, seed) -> fixed
tip: Worley (cellular) F1 distance to the nearest cell point.
order: 5
ns: Noise
member: cellular2
---

Samples **cellular (Worley) noise** at <code>(x, y)</code> and returns the F1 distance — the distance to the nearest feature point — as a <a href="type-fixed"><code>fixed</code></a> (roughly <code>[0, 1.5]</code>). Each lattice cell holds one feature point placed by its hash; scanning the 3×3 neighbourhood finds the closest one. The distance field forms Voronoi cells, which are exactly the structure you want for stone and cracked textures, biome or region boundaries, and scattered-feature layouts. Small distances mark cell centres; ridges appear where two cells meet.

Pair it with <a href="noise-cellular2_id"><code>Noise.cellular2_id</code></a> to also know *which* cell you are in. Deterministic in fixed point across platforms and runs.

Parameters:
- `x`, `y` — the sample coordinates (`fixed`)
- `seed` — the field selector

```ludic
program Cellular {
  entry {
    let seed = 7
    let d = Noise.cellular2(fixed(5) / fixed(4), fixed(3) / fixed(4), seed)
    print(Math.floor(d * fixed(1000)))   # distance to nearest cell point
  }
}
```
