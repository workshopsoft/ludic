---
id: percent-of
name: Percent.of
category: percent
kind: namespace-method
tokens: Percent.of
sig: Percent.of(num, den) -> fixed
tip: Clamped ratio num / den.
order: 1
ns: Percent
member: of
---

Forms the ratio <code>num / den</code> clamped to [0, 1] (0 when <code>den</code> is 0) — a filled-fraction from a part and a whole.

```ludic
program Demo {
  handler Step phase Update {
    let filled = Percent.of(current, maximum)
  }
}
```
