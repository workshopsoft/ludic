---
id: angle-to_degrees
name: Angle.to_degrees
category: angle
kind: namespace-method
tokens: Angle.to_degrees
sig: Angle.to_degrees(a) -> fixed
tip: Radians back to degrees.
order: 1
ns: Angle
member: to_degrees
---

Converts a radian angle back to degrees — handy for display or debugging.

```ludic
program Demo {
  handler Step phase Update {
    let deg = Angle.to_degrees(facing)
  }
}
```
