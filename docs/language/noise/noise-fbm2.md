---
id: noise-fbm2
name: Noise.fbm2
category: noise
kind: namespace-method
tokens: Noise.fbm2
sig: Noise.fbm2(x, y, seed, octaves) -> fixed
tip: Fractal Brownian motion — octaves of simplex, in [-1, 1].
order: 4
ns: Noise
member: fbm2
---

Samples **fractal Brownian motion** at <code>(x, y)</code>: it stacks <code>octaves</code> layers of <a href="noise-simplex2"><code>simplex2</code></a>, each at double the frequency and half the amplitude of the last, and normalises by the total amplitude so the result stays a <a href="type-fixed"><code>fixed</code></a> in <code>[-1, 1]</code>. Layering this way adds fine detail on top of broad shapes — the standard recipe for natural-looking terrain, clouds, and marble. More octaves means more detail (and more cost); 4–6 is typical.

Each octave uses a different derived seed, and the whole thing is deterministic in fixed point across platforms and runs.

Parameters:
- `x`, `y` — the sample coordinates (`fixed`)
- `seed` — the base field selector (each octave derives from it)
- `octaves` — how many layers to sum (higher = more detail)

```ludic
program Fbm {
  entry {
    let seed = 1337
    let h = Noise.fbm2(fixed(2) / fixed(7), fixed(9) / fixed(7), seed, 5)
    print(Math.floor(Noise.unit(h) * fixed(100)))   # detailed 0..100 height
  }
}
```
