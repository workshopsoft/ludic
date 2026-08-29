---
id: hash-mix64
name: Hash.mix64
category: hash
kind: namespace-method
tokens: Hash.mix64
sig: Hash.mix64(x) -> long
tip: Avalanche one 64-bit integer into a well-scrambled value.
order: 8
ns: Hash
member: mix64
---

The 64-bit counterpart of <a href="hash-mix"><code>Hash.mix</code></a>: the <a href="https://en.wikipedia.org/wiki/MurmurHash">MurmurHash3</a> <code>fmix64</code> finalizer (shift by 33, multiply, repeat). It thoroughly scrambles a <code>long</code>, so consecutive or structured inputs map to unrelated-looking outputs — ideal for turning a large counter, packed coordinate, or 64-bit id into a random-looking seed. An <code>int</code> argument widens to 64 bits first. Deterministic; <code>Hash.mix64(0)</code> is <code>0</code>.

Parameters:
- `x` — the integer to avalanche (widened to `long`)

```ludic
program Seeds64 {
  entry {
    let base: long = Hash.of64("chunk")
    print(Hash.mix64(base))
    print(Hash.mix64(base + 1))   # a neighbouring input -> an unrelated seed
  }
}
```
