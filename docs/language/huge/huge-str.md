---
id: huge-str
name: Huge.str
category: huge
kind: namespace-method
tokens: Huge.str
sig: Huge.str(a) -> string
tip: Render as scientific text like 1.23e45.
order: 9
ns: Huge
member: str
---

Renders the value in scientific form, like <code>1.23e45</code> (a two-decimal mantissa). This is how you show an idle magnitude on the HUD.

```ludic
program Demo {
  handler Step phase Update {
    Screen.draw_text(8, 8, Huge.str(gold), Color.White, 1)
  }
}
```
