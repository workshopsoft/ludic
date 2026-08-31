---
id: angle-sin
name: Angle.sin
category: angle
kind: namespace-method
tokens: Angle.sin
sig: Angle.sin(a) -> fixed
tip: Sine of an angle.
order: 3
ns: Angle
member: sin
---

Returns the sine of the angle, using the deterministic fixed-point trig.

```ludic
program Demo {
  handler Step phase Update {
    let dy = Angle.sin(facing)
  }
}
```
