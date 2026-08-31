---
id: bigint-eq
name: BigInt.eq
category: bigint
kind: namespace-method
tokens: BigInt.eq
sig: BigInt.eq(a, b) -> bool
tip: True when two big integers are equal.
order: 10
ns: BigInt
member: eq
---

Returns true when two big integers have exactly the same value.

```ludic
program Demo {
  handler Step phase Update {
    if BigInt.eq(score, target) { win() }
  }
}
```
