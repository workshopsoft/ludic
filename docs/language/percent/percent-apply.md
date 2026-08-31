---
id: percent-apply
name: Percent.apply
category: percent
kind: namespace-method
tokens: Percent.apply
sig: Percent.apply(value, p) -> fixed
tip: Scale a value by a clamped percent.
order: 3
ns: Percent
member: apply
---

Scales <code>value</code> by a clamped fraction <code>p</code> — for example, applying a damage-reduction percentage.

```ludic
program Demo {
  handler Step phase Update {
    let dealt = Percent.apply(damage, 0.75)
  }
}
```
