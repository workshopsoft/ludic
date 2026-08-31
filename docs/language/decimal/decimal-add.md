---
id: decimal-add
name: Decimal.add
category: decimal
kind: namespace-method
tokens: Decimal.add
sig: Decimal.add(a, b) -> Decimal
tip: Exact sum of two decimals.
order: 2
ns: Decimal
member: add
---

Returns the exact sum, aligning the two scales first so nothing is rounded. <code>0.10 + 0.20</code> is exactly <code>0.30</code>.

```ludic
program Demo {
  handler Step phase Update {
    let total = Decimal.add(subtotal, tax)
  }
}
```
