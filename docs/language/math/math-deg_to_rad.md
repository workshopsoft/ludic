---
id: math-deg_to_rad
name: Math.deg_to_rad
category: math
kind: namespace-method
tokens: Math.deg_to_rad
sig: Math.deg_to_rad(degrees) -> fixed
tip: Convert degrees to radians.
order: 18
ns: Math
member: deg_to_rad
---

Converts an angle from degrees to radians (multiplying by <code>pi/180</code>), since <code>Math.sin</code>/<code>Math.cos</code>/<code>Math.tan</code> all take radians. Use it when your data or design speaks in degrees — a 90-degree turn, a 45-degree cone — and you need to feed it to the trig functions.

```ludic
program Demo {
  handler Step phase Update {
    let r = Math.sin(Math.deg_to_rad(90.0))   # ~1.0
  }
}
```
