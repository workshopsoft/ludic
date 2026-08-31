---
id: bigint-mod
name: BigInt.mod
category: bigint
kind: namespace-method
tokens: BigInt.mod
sig: BigInt.mod(a, d) -> int
tip: Remainder of a big integer divided by an int.
order: 8
ns: BigInt
member: mod
---

Returns the remainder of <code>a</code> divided by an <code>int</code> divisor, carrying the sign of <code>a</code>. Pairs with <code>BigInt.div</code>.

```ludic
program Demo {
  handler Step phase Update {
    let leftover = BigInt.mod(pot, players)
  }
}
```
