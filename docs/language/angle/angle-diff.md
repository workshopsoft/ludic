---
id: angle-diff
name: Angle.diff
category: angle
kind: namespace-method
tokens: Angle.diff
sig: Angle.diff(a, b) -> fixed
tip: Shortest signed rotation from a to b.
order: 6
ns: Angle
member: diff
---

Returns the shortest signed rotation from <code>a</code> to <code>b</code>, in [-pi, pi) — positive to turn one way, negative the other.

```ludic
program Demo {
  handler Step phase Update {
    let steer = Angle.diff(facing, target)
  }
}
```
