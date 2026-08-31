---
id: bigint-div
name: BigInt.div
category: bigint
kind: namespace-method
tokens: BigInt.div
sig: BigInt.div(a, d) -> BigInt
tip: Divide a big integer by an int (toward zero).
order: 7
ns: BigInt
member: div
---

Divides a <code>BigInt</code> by an <code>int</code> divisor, truncating toward zero. Handy for splitting an exact total into equal shares.

```ludic
program Demo {
  handler Step phase Update {
    let each = BigInt.div(pot, players)
  }
}
```
