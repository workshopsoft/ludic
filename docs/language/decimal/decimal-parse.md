---
id: decimal-parse
name: Decimal.parse
category: decimal
kind: namespace-method
tokens: Decimal.parse
sig: Decimal.parse(text) -> Decimal
tip: Parse decimal text like "19.99".
order: 1
ns: Decimal
member: parse
---

Parses text like <code>"19.99"</code> or <code>"0.10"</code> into an exact <code>Decimal</code>, remembering how many digits followed the point. This is how you enter a price the way binary floating point never could.

```ludic
program Demo {
  handler Step phase Update {
    let price = Decimal.parse("19.99")
  }
}
```
