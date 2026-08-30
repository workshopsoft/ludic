---
id: noise-simplex2
name: Noise.simplex2
category: noise
kind: namespace-method
tokens: Noise.simplex2
sig: Noise.simplex2(x, y, seed) -> fixed
tip: 2D simplex noise, the organic default, in [-1, 1].
order: 3
ns: Noise
member: simplex2
---

Samples 2D **simplex noise** at <code>(x, y)</code> for the given <code>seed</code> and returns a <a href="type-fixed"><code>fixed</code></a> in <code>[-1, 1]</code>. Simplex noise sums contributions from the three corners of a skewed triangular cell, which gives it fewer of the axis-aligned directional artifacts that gradient noise can show — making it the recommended default for organic fields like terrain height and biome masks.

Deterministic in fixed point across platforms and runs, and the generator that <a href="noise-fbm2"><code>Noise.fbm2</code></a> layers by default. Scale the coordinates to set feature size.

Parameters:
- `x`, `y` — the sample coordinates (`fixed`)
- `seed` — the field selector

```ludic
program Simplex {
  entry {
    let seed = 1337
    let n = Noise.simplex2(fixed(4) / fixed(9), fixed(6) / fixed(9), seed)
    print(Math.floor(Noise.unit(n) * fixed(100)))
  }
}
```
