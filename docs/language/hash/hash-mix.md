---
id: hash-mix
name: Hash.mix
category: hash
kind: namespace-method
tokens: Hash.mix
sig: Hash.mix(x) -> int
tip: Avalanche one integer into a well-scrambled value.
order: 4
ns: Hash
member: mix
---

Scrambles a single integer so its bits are thoroughly mixed — the <a href="https://en.wikipedia.org/wiki/MurmurHash">MurmurHash3</a> <code>fmix32</code> finalizer (shift/multiply/shift). Nearby inputs like <code>0</code>, <code>1</code>, <code>2</code> map to values that look unrelated, which is exactly what you want when turning a counter, entity id, or frame number into a random-looking seed. It is deterministic and self-inverse-free: the same input always gives the same output. <code>Hash.mix(0)</code> is <code>0</code>. For folding several numbers together use <a href="hash-combine"><code>Hash.combine</code></a>.

Parameters:
- `x` — the integer to avalanche

```ludic
program Seeds {
  entry {
    var i = 0
    while i < 4 {
      print(Hash.mix(i))   # consecutive counters -> unrelated-looking seeds
      i = i + 1
    }
  }
}
```
