---
id: hash-fnv1a
name: Hash.fnv1a
category: hash
kind: namespace-method
tokens: Hash.fnv1a
sig: Hash.fnv1a(s) -> int
tip: FNV-1a 32-bit, named explicitly.
order: 2
ns: Hash
member: fnv1a
---

The <a href="https://en.wikipedia.org/wiki/Fowler%E2%80%93Noll%E2%80%93Vo_hash_function">FNV-1a</a> hash of a string's bytes, as an explicit 32-bit algorithm. It starts from the standard offset basis <code>0x811c9dc5</code> and, for each byte, XORs the byte in and multiplies by the FNV prime <code>0x01000193</code>. Small, allocation-free, and well-distributed for short strings — ideal for map keys and content ids. This is the same function <a href="hash-of"><code>Hash.of</code></a> currently delegates to; call <code>Hash.fnv1a</code> when you want to pin the algorithm by name so the value stays fixed even if the default changes.

Parameters:
- `s` — the string to hash

```ludic
program Fnv {
  entry {
    print(Hash.fnv1a(""))            # the empty string -> the offset basis
    print(Hash.fnv1a("grass_tile"))
  }
}
```
