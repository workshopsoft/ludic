---
id: bigint-sub
name: BigInt.sub
category: bigint
kind: namespace-method
tokens: BigInt.sub
sig: BigInt.sub(a, b) -> BigInt
tip: Exact difference of two big integers.
order: 3
ns: BigInt
member: sub
---

Returns the exact difference <code>a - b</code>; the result is negative when <code>b</code> is larger.

```ludic
program Demo {
  handler Step phase Update {
    let remaining = BigInt.sub(bank, cost)
  }
}
```
