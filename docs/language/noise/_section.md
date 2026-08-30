---
id: noise
title: Noise
order: 6
---

Procedural noise — the primitive that terrain, caves, biomes, textures, clouds, wind, and object placement are built on. Every generator is implemented in Q16.16 **fixed point** over an integer permutation hash seeded from an explicit seed, so a given seed reproduces the *exact* same field on every platform and every run: native, headless, and (later) wasm all agree bit-for-bit. That is a real edge over float-based engines, whose worlds can drift subtly across CPUs and break shared-seed multiplayer or replays.

Coordinates are <a href="type-fixed"><code>fixed</code></a> values. The integer part of a coordinate selects a lattice cell and the fraction interpolates within it, so you scale feature size by sampling at a fractional *frequency* (e.g. multiply coordinates by <code>1/64</code>). Outputs are <code>fixed</code> normalised to <code>[-1, 1]</code>; <a href="noise-unit"><code>Noise.unit</code></a> remaps that to <code>[0, 1]</code> when you want a height or a probability.

Pick a generator by feel: <a href="noise-value2"><code>value2</code></a> is cheap and blocky; <a href="noise-perlin2"><code>perlin2</code></a> is the classic gradient noise; <a href="noise-simplex2"><code>simplex2</code></a> is the organic default with fewer directional artifacts; <a href="noise-fbm2"><code>fbm2</code></a> stacks octaves of simplex for natural, detailed fields; and <a href="noise-cellular2"><code>cellular2</code></a> (Worley) gives Voronoi-cell structure for stone, cracks, and biome boundaries. Every sampler is a pure function of <code>(x, y, seed)</code> — no global state, no allocation — so it is safe to call across a whole worldgen pass or a per-pixel fill.

Seed worldgen from its own seed (or a dedicated <a href="ns-Random"><code>Random</code></a> stream), kept separate from gameplay RNG, so generating the world never desyncs the simulation.
