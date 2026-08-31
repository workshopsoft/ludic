---
id: angle-wrap
name: Angle.wrap
category: angle
kind: namespace-method
tokens: Angle.wrap
sig: Angle.wrap(a) -> fixed
tip: Normalize any radian value to [-pi, pi).
order: 2
ns: Angle
member: wrap
---

Normalizes any radian value into [-pi, pi), so accumulated rotation never runs away.

```ludic
program Demo {
  handler Step phase Update {
    heading = Angle.wrap(heading + spin)
  }
}
```
