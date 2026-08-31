---
id: decimal-from
name: Decimal.from
category: decimal
kind: namespace-method
tokens: Decimal.from
sig: Decimal.from(value) -> Decimal
tip: Turn a whole int into a Decimal.
order: 0
ns: Decimal
member: from
---

Lifts a whole <code>int</code> into a <code>Decimal</code> with scale zero — a starting point for exact money arithmetic.

```ludic
program Demo {
  handler Step phase Update {
    let qty = Decimal.from(3)
  }
}
```
