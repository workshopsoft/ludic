---
id: datetime-format
name: DateTime.format
category: datetime
kind: namespace-method
tokens: DateTime.format
sig: DateTime.format(dt, pattern) -> string
tip: Render an instant as text using a token pattern.
order: 10
ns: DateTime
member: format
---

Renders the instant <code>dt</code> as a string, filling the tokens in <code>pattern</code> with zero-padded fields and copying every other character through verbatim. The pattern <b>must be a string literal</b> &mdash; it is expanded at compile time, so there is no runtime pattern scanner. Recognised tokens: <code>YYYY</code> (4-digit year), <code>YY</code> (2-digit year), <code>MM</code> (month), <code>DD</code> (day), <code>HH</code> (hour, 24h), <code>mm</code> (minute), <code>ss</code> (second).

```ludic
program Demo {
  handler Step phase Update {
    let t = DateTime.from(2026, 8, 30, 7, 5, 9)
    let stamp = DateTime.format(t, "YYYY-MM-DD HH:mm:ss")   # "2026-08-30 07:05:09"
  }
}
```
