---
id: decimal-eq
name: Decimal.eq
category: decimal
kind: namespace-method
tokens: Decimal.eq
sig: Decimal.eq(a, b) -> bool
tip: True when two decimals are equal in value.
order: 7
ns: Decimal
member: eq
---

Returns true when two decimals are equal in value even if written at different scales — <code>1.5</code> equals <code>1.50</code>.

```ludic
program Demo {
  handler Step phase Update {
    if Decimal.eq(paid, price) { accept() }
  }
}
```
