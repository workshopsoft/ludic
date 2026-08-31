---
id: bigint-pow
name: BigInt.pow
category: bigint
kind: namespace-method
tokens: BigInt.pow
sig: BigInt.pow(a, exp) -> BigInt
tip: Raise a big integer to an int power.
order: 6
ns: BigInt
member: pow
---

Raises <code>a</code> to the (non-negative) integer power <code>exp</code> by binary exponentiation — an exact way to reach astronomically large magnitudes.

```ludic
program Demo {
  handler Step phase Update {
    let googol = BigInt.pow(BigInt.from(10), 100)
  }
}
```
