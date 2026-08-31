---
id: angle-from_degrees
name: Angle.from_degrees
category: angle
kind: namespace-method
tokens: Angle.from_degrees
sig: Angle.from_degrees(d) -> fixed
tip: Degrees to a wrapped radian angle.
order: 0
ns: Angle
member: from_degrees
---

Converts degrees to radians and wraps the result into [-pi, pi). The natural way to author a heading a designer types in degrees.

```ludic
program Demo {
  handler Step phase Update {
    let facing = Angle.from_degrees(90.0)
  }
}
```
