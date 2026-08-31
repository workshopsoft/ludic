---
id: decimal-sub
name: Decimal.sub
category: decimal
kind: namespace-method
tokens: Decimal.sub
sig: Decimal.sub(a, b) -> Decimal
tip: Exact difference of two decimals.
order: 3
ns: Decimal
member: sub
---

Returns the exact difference <code>a - b</code>, aligning scales so balances stay penny-accurate.

```ludic
program Demo {
  handler Step phase Update {
    let change = Decimal.sub(paid, price)
  }
}
```
