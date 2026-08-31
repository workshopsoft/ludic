---
id: decimal-cmp
name: Decimal.cmp
category: decimal
kind: namespace-method
tokens: Decimal.cmp
sig: Decimal.cmp(a, b) -> int
tip: Compare two decimals: -1, 0, or 1.
order: 6
ns: Decimal
member: cmp
---

Compares two decimals regardless of their scales, returning <code>-1</code>, <code>0</code>, or <code>1</code>.

```ludic
program Demo {
  handler Step phase Update {
    if Decimal.cmp(balance, price) < 0 { deny() }
  }
}
```
