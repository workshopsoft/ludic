---
id: angle-add
name: Angle.add
category: angle
kind: namespace-method
tokens: Angle.add
sig: Angle.add(a, b) -> fixed
tip: Add two angles (wrapped).
order: 5
ns: Angle
member: add
---

Adds two angles and wraps the result back into range.

```ludic
program Demo {
  handler Step phase Update {
    facing = Angle.add(facing, turnRate)
  }
}
```
