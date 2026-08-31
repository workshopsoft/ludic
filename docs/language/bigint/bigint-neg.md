---
id: bigint-neg
name: BigInt.neg
category: bigint
kind: namespace-method
tokens: BigInt.neg
sig: BigInt.neg(a) -> BigInt
tip: Negate a big integer.
order: 5
ns: BigInt
member: neg
---

Returns <code>-a</code> — the same magnitude with the opposite sign.

```ludic
program Demo {
  handler Step phase Update {
    let debt = BigInt.neg(balance)
  }
}
```
