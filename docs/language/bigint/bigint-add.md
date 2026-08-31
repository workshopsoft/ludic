---
id: bigint-add
name: BigInt.add
category: bigint
kind: namespace-method
tokens: BigInt.add
sig: BigInt.add(a, b) -> BigInt
tip: Exact sum of two big integers.
order: 2
ns: BigInt
member: add
---

Returns the exact sum <code>a + b</code>. There is no overflow — the result grows as many digits as it needs.

```ludic
program Demo {
  handler Step phase Update {
    let total = BigInt.add(score, reward)
  }
}
```
