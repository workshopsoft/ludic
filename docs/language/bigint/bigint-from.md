---
id: bigint-from
name: BigInt.from
category: bigint
kind: namespace-method
tokens: BigInt.from
sig: BigInt.from(value) -> BigInt
tip: Turn a plain int into a BigInt.
order: 0
ns: BigInt
member: from
---

Lifts a plain <code>int</code> into a <code>BigInt</code>, the starting point for exact arbitrary-precision arithmetic that would overflow an ordinary integer.

```ludic
program Demo {
  handler Step phase Update {
    let n = BigInt.from(1000000)
  }
}
```
