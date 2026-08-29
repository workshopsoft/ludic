---
id: fn-words
name: words
category: builtins
kind: builtin
tokens: words
sig: words(n) -> words
tip: Allocate a raw buffer of n 32-bit words, indexable with [i].
order: 50
---

Allocates a raw buffer of <code>n</code> 32-bit words and returns a <code>words</code> value you can index with <code>buffer[i]</code> to read or write each word as an <code>int</code>. Use it when you want a flat, fixed-size numeric scratch array — a lookup table, a small ring buffer, or per-slot counters — without declaring a model. It is lower-level than a growable <code>[]int</code> slice: the size is chosen up front and there is no <code>push</code>. For byte-granular storage use <code>bytes</code> instead.

Parameters:
- `n` — the number of 32-bit words to allocate

```ludic
program WordScratch {
  handler SumScores phase Start {
    let scores = words(3)
    scores[0] = 10
    scores[1] = 20
    scores[2] = 30
    var total: int = 0
    for index in 0 .. 3 {
      total = total + scores[index]
    }
    print(total)
  }
}
```
