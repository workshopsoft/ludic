---
id: math-asin
name: Math.asin
category: math
kind: namespace-method
tokens: Math.asin
sig: Math.asin(x) -> fixed
tip: The arcsine of a value, in radians.
order: 27
ns: Math
member: asin
---

Returns the angle in radians whose sine is <code>x</code>, in <code>-pi/2</code>..<code>pi/2</code>. The input should be in <code>-1.0</code>..<code>1.0</code>. Built from <code>Math.atan2</code> and <code>Math.sqrt</code>, so it is deterministic.

```ludic
program Demo {
  handler Step phase Update {
    let angle = Math.asin(height / radius)
  }
}
```
