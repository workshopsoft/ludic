---
id: noise-perlin2
name: Noise.perlin2
category: noise
kind: namespace-method
tokens: Noise.perlin2
sig: Noise.perlin2(x, y, seed) -> fixed
tip: 2D Perlin gradient noise, deterministic, in [-1, 1].
order: 2
ns: Noise
member: perlin2
---

Samples 2D **Perlin gradient noise** at <code>(x, y)</code> for the given <code>seed</code> and returns a <a href="type-fixed"><code>fixed</code></a> in <code>[-1, 1]</code>. Instead of a random value per lattice point, Perlin places a random gradient at each corner and interpolates their dot products with the offset vectors — which gives smoother, more natural gradients than value noise, the familiar look of classic terrain and cloud fields. By construction the value is exactly <code>0</code> at every integer lattice point.

Deterministic in fixed point across platforms and runs. Scale the coordinates to set feature size, and stack octaves with <a href="noise-fbm2"><code>Noise.fbm2</code></a> for richer detail.

Parameters:
- `x`, `y` — the sample coordinates (`fixed`)
- `seed` — the field selector

```ludic
program Perlin {
  entry {
    let seed = 1337
    if Noise.perlin2(fixed(0), fixed(0), seed) == 0 { print(1) }   # zero at the lattice
    let n = Noise.perlin2(fixed(10) / fixed(3), fixed(7) / fixed(3), seed)
    print(Math.floor(n * fixed(1000)))
  }
}
```
