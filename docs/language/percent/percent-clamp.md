---
id: percent-clamp
name: Percent.clamp
category: percent
kind: namespace-method
tokens: Percent.clamp
sig: Percent.clamp(v) -> fixed
tip: Clamp any fixed into [0, 1].
order: 0
ns: Percent
member: clamp
---

Pins any <code>fixed</code> into the range [0, 1] — a health fraction or volume that can never slip out of bounds.

```ludic
program Demo {
  handler Step phase Update {
    let hp = Percent.clamp(health)
  }
}
```
