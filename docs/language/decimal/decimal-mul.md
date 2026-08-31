---
id: decimal-mul
name: Decimal.mul
category: decimal
kind: namespace-method
tokens: Decimal.mul
sig: Decimal.mul(a, b) -> Decimal
tip: Exact product of two decimals.
order: 4
ns: Decimal
member: mul
---

Returns the exact product; the result's scale is the sum of the operands' scales, so no precision is lost.

```ludic
program Demo {
  handler Step phase Update {
    let line = Decimal.mul(price, quantity)
  }
}
```
