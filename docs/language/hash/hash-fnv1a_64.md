---
id: hash-fnv1a_64
name: Hash.fnv1a_64
category: hash
kind: namespace-method
tokens: Hash.fnv1a_64
sig: Hash.fnv1a_64(s) -> long
tip: FNV-1a 64-bit, named explicitly.
order: 7
ns: Hash
member: fnv1a_64
---

The 64-bit <a href="https://en.wikipedia.org/wiki/Fowler%E2%80%93Noll%E2%80%93Vo_hash_function">FNV-1a</a> hash of a string's bytes, returned as a <code>long</code>. It uses the standard 64-bit offset basis <code>0xcbf29ce484222325</code> and prime <code>0x100000001b3</code>: for each byte, XOR it in and multiply by the prime. Its wider output makes accidental collisions vanishingly unlikely for the id and registry use cases games hit. This is the function <a href="hash-of64"><code>Hash.of64</code></a> delegates to; call <code>Hash.fnv1a_64</code> when you want the algorithm pinned by name.

Parameters:
- `s` — the string to hash

```ludic
program Fnv64 {
  entry {
    print(Hash.fnv1a_64(""))            # the empty string -> the 64-bit offset basis
    print(Hash.fnv1a_64("grass_tile"))
  }
}
```
