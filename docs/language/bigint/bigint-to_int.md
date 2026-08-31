---
id: bigint-to_int
name: BigInt.to_int
category: bigint
kind: namespace-method
tokens: BigInt.to_int
sig: BigInt.to_int(a) -> int
tip: Narrow a big integer to a plain int (clamped).
order: 12
ns: BigInt
member: to_int
---

Returns the value as a plain <code>int</code> when it fits in 32 bits, clamping to the int min/max otherwise. Use it to feed a small big-integer back into ordinary code.

```ludic
program Demo {
  handler Step phase Update {
    let n = BigInt.to_int(BigInt.from(2024))
  }
}
```
