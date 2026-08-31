---
id: decimal-rescale
name: Decimal.rescale
category: decimal
kind: namespace-method
tokens: Decimal.rescale
sig: Decimal.rescale(d, places) -> Decimal
tip: Change precision (truncates toward zero).
order: 9
ns: Decimal
member: rescale
---

Changes the number of fractional digits. Increasing precision is exact; decreasing it truncates toward zero — how you round a computed price down to whole cents.

```ludic
program Demo {
  handler Step phase Update {
    let cents = Decimal.rescale(raw, 2)
  }
}
```
