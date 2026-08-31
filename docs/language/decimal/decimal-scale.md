---
id: decimal-scale
name: Decimal.scale
category: decimal
kind: namespace-method
tokens: Decimal.scale
sig: Decimal.scale(d) -> int
tip: The number of digits after the point.
order: 8
ns: Decimal
member: scale
---

Returns the current scale — how many digits sit after the decimal point.

```ludic
program Demo {
  handler Step phase Update {
    let places = Decimal.scale(price)
  }
}
```
