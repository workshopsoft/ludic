---
id: hash-of64
name: Hash.of64
category: hash
kind: namespace-method
tokens: Hash.of64
sig: Hash.of64(s) -> long
tip: The fast default 64-bit string hash.
order: 6
ns: Hash
member: of64
---

The 64-bit counterpart of <a href="hash-of"><code>Hash.of</code></a>: hashes a string to a <code>long</code> instead of a 32-bit <code>int</code>. Use it when you want far fewer collisions than 32 bits can give — large content-id spaces, asset registries, or network identifiers where two different strings sharing a hash would be a real risk. Currently it is <a href="hash-fnv1a_64"><code>Hash.fnv1a_64</code></a>, FNV-1a over the bytes. Deterministic like every hash here: the same string always gives the same 64-bit value.

Parameters:
- `s` — the string to hash

```ludic
program Ids64 {
  entry {
    let grass: long = Hash.of64("grass_tile")
    let water: long = Hash.of64("water_tile")
    print(grass)
    print(water)
  }
}
```
