---
id: angle-lerp
name: Angle.lerp
category: angle
kind: namespace-method
tokens: Angle.lerp
sig: Angle.lerp(a, b, t) -> fixed
tip: Interpolate along the shortest arc.
order: 7
ns: Angle
member: lerp
---

Interpolates from <code>a</code> toward <code>b</code> along the shortest arc (t is a fixed 0..1), so a turn never spins the long way around.

```ludic
program Demo {
  handler Step phase Update {
    facing = Angle.lerp(facing, target, 0.1)
  }
}
```
