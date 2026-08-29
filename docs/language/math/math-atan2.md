---
id: math-atan2
name: Math.atan2
category: math
kind: namespace-method
tokens: Math.atan2
sig: Math.atan2(y, x) -> fixed
tip: The angle of the vector (x, y), in radians.
order: 26
ns: Math
member: atan2
---

Returns the angle in radians from the positive x-axis to the point <code>(x, y)</code>, in the full range <code>-pi</code>..<code>pi</code> — the standard way to get a heading from a direction vector. Note the argument order is <code>y</code> then <code>x</code>. Deterministic fixed-point, accurate to within about a degree.

```ludic
program Demo {
  handler Step phase Update {
    let heading = Math.atan2(target_y - y, target_x - x)
  }
}
```
