---
id: hash-combine
name: Hash.combine
category: hash
kind: namespace-method
tokens: Hash.combine
sig: Hash.combine(...) -> int
tip: Fold several ints into one deterministic seed.
order: 5
ns: Hash
member: combine
---

Mixes any number of integers into a single 32-bit value. It folds the arguments left to right with the classic hash-combine step (each value is spread with the golden-ratio constant <code>0x9e3779b9</code> and stirred into the running seed), so the result depends on every input and on their order — <code>Hash.combine(1, 2, 3)</code> and <code>Hash.combine(3, 2, 1)</code> differ. The whole point is a per-thing deterministic seed: hash a world seed with a chunk's coordinates to drive procedural generation, so the same chunk always regenerates identically. Pair it with the noise and random libraries, which take a seed.

Parameters:
- `...` — the integers to combine (one or more)

```ludic
program ChunkSeed {
  entry {
    let world_seed = 1337
    let cx = 4
    let cy = -2
    let seed = Hash.combine(world_seed, cx, cy)  # this chunk's stable seed
    print(seed)
    print(Hash.combine(world_seed, cx, cy) == seed)  # 1 — reproducible
  }
}
```
