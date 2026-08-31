---
id: bigint-is_zero
name: BigInt.is_zero
category: bigint
kind: namespace-method
tokens: BigInt.is_zero
sig: BigInt.is_zero(a) -> bool
tip: True when a big integer is zero.
order: 11
ns: BigInt
member: is_zero
---

Returns true when the value is exactly zero — cheaper and clearer than comparing against <code>BigInt.from(0)</code>.

```ludic
program Demo {
  handler Step phase Update {
    if BigInt.is_zero(balance) { gameOver() }
  }
}
```
