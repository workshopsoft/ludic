---
id: angle-cos
name: Angle.cos
category: angle
kind: namespace-method
tokens: Angle.cos
sig: Angle.cos(a) -> fixed
tip: Cosine of an angle.
order: 4
ns: Angle
member: cos
---

Returns the cosine of the angle, using the deterministic fixed-point trig.

```ludic
program Demo {
  handler Step phase Update {
    let dx = Angle.cos(facing)
  }
}
```
