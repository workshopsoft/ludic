---
id: bigint-cmp
name: BigInt.cmp
category: bigint
kind: namespace-method
tokens: BigInt.cmp
sig: BigInt.cmp(a, b) -> int
tip: Compare two big integers: -1, 0, or 1.
order: 9
ns: BigInt
member: cmp
---

Compares two big integers, returning <code>-1</code>, <code>0</code>, or <code>1</code> as <code>a</code> is less than, equal to, or greater than <code>b</code>.

```ludic
program Demo {
  handler Step phase Update {
    if BigInt.cmp(score, best) > 0 { best = score }
  }
}
```
