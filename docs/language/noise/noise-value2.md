---
id: noise-value2
name: Noise.value2
category: noise
kind: namespace-method
tokens: Noise.value2
sig: Noise.value2(x, y, seed) -> fixed
tip: 2D value (lattice) noise, deterministic, in [-1, 1].
order: 1
ns: Noise
member: value2
---

Samples 2D **value noise** at <code>(x, y)</code> for the given <code>seed</code> and returns a <a href="type-fixed"><code>fixed</code></a> in <code>[-1, 1]</code>. Value noise assigns a pseudo-random value to each integer lattice point and smoothly interpolates between them with a quintic fade — the cheapest generator here, with a slightly blocky, retro character that suits low-detail height fields, dithering, and per-cell variation.

Because it is a pure function of <code>(x, y, seed)</code> in fixed point, the same arguments always produce the same value on every platform. Sample at a fractional frequency (scale the coordinates) to change feature size.

Parameters:
- `x`, `y` — the sample coordinates (`fixed`); the integer part picks a cell
- `seed` — the field selector; different seeds give independent worlds

```ludic
program Value {
  entry {
    let seed = 1337
    let n = Noise.value2(fixed(3) / fixed(8), fixed(5) / fixed(8), seed)
    print(Math.floor(Noise.unit(n) * fixed(100)))   # a 0..100 height
  }
}
```
