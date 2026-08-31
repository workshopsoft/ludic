---
id: decimal-str
name: Decimal.str
category: decimal
kind: namespace-method
tokens: Decimal.str
sig: Decimal.str(d) -> string
tip: Render a decimal as text.
order: 10
ns: Decimal
member: str
---

Renders the value as text with its decimal point in place (a leading <code>-</code> when negative). This is how you display or serialize money.

```ludic
program Demo {
  handler Step phase Update {
    Screen.draw_text(8, 8, Decimal.str(balance), Color.White, 1)
  }
}
```
