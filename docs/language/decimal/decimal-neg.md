---
id: decimal-neg
name: Decimal.neg
category: decimal
kind: namespace-method
tokens: Decimal.neg
sig: Decimal.neg(a) -> Decimal
tip: Negate a decimal.
order: 5
ns: Decimal
member: neg
---

Returns <code>-a</code> at the same scale — the same magnitude with the opposite sign.

```ludic
program Demo {
  handler Step phase Update {
    let refund = Decimal.neg(charge)
  }
}
```
