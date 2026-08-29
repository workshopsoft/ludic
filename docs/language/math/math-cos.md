---
id: math-cos
name: Math.cos
category: math
kind: namespace-method
tokens: Math.cos
sig: Math.cos(radians) -> fixed
tip: Cosine of an angle in radians.
order: 13
ns: Math
member: cos
---

Returns the cosine of <code>radians</code> as a <code>fixed</code> in <code>-1.0</code>..<code>1.0</code>, computed as <code>Math.sin(radians + pi/2)</code> off the same deterministic table. Use <code>Math.cos</code> and <code>Math.sin</code> together to convert an angle into an <code>(x, y)</code> direction — for orbits, aiming, or steering.

```ludic
program Demo {
  handler Step phase Update {
    let x = center_x + Math.cos(angle) * radius
  }
}
```
