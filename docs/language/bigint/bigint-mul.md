---
id: bigint-mul
name: BigInt.mul
category: bigint
kind: namespace-method
tokens: BigInt.mul
sig: BigInt.mul(a, b) -> BigInt
tip: Exact product of two big integers.
order: 4
ns: BigInt
member: mul
---

Returns the exact product <code>a * b</code>. Multiplying two large counters never loses precision — the classic idle-game growth step.

```ludic
program Demo {
  handler Step phase Update {
    let next = BigInt.mul(count, multiplier)
  }
}
```
