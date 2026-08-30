---
id: noise-unit
name: Noise.unit
category: noise
kind: namespace-method
tokens: Noise.unit
sig: Noise.unit(n) -> fixed
tip: Remap a [-1,1] noise sample to [0,1].
order: 7
ns: Noise
member: unit
---

Remaps a noise sample from <code>[-1, 1]</code> to <code>[0, 1]</code> — literally <code>n / 2 + 0.5</code> — returning a <a href="type-fixed"><code>fixed</code></a>. The signed range is the natural output of the samplers, but heights, densities, probabilities, and colour ramps usually want the unsigned <code>[0, 1]</code> range; <code>unit</code> is the one-step conversion. It is a plain affine remap, so <code>unit(-1) == 0</code>, <code>unit(0) == 0.5</code>, and <code>unit(1) == 1</code>.

Parameters:
- `n` — a sample in `[-1, 1]` (e.g. from `perlin2`/`simplex2`/`fbm2`)

```ludic
program Unit {
  entry {
    let n = Noise.simplex2(fixed(1) / fixed(2), fixed(1) / fixed(2), 1337)
    let height = Math.floor(Noise.unit(n) * fixed(64))   # 0..64 tiles
    print(height)
  }
}
```
