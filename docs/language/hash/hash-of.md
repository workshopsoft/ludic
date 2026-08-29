---
id: hash-of
name: Hash.of
category: hash
kind: namespace-method
tokens: Hash.of
sig: Hash.of(s) -> int
tip: The fast default string hash.
order: 1
ns: Hash
member: of
---

The go-to hash for a string: turns text like <code>"grass_tile"</code> into a fast, stable 32-bit integer handle. <code>Hash.of</code> is the default when you don't care which algorithm is used — currently it is <a href="hash-fnv1a"><code>Hash.fnv1a</code></a>, FNV-1a over the bytes. Reach for it to key a lookup table by name, give content a compact id, or detect that a config string changed. The result is deterministic: the same string always produces the same value, on every platform and run. It is not for security — see the section note.

Parameters:
- `s` — the string to hash

```ludic
program TileIds {
  entry {
    let grass = Hash.of("grass_tile")   # a stable integer id for this tile name
    let water = Hash.of("water_tile")
    print(grass)
    print(water)
  }
}
```
