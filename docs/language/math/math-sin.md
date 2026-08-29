---
id: math-sin
name: Math.sin
category: math
kind: namespace-method
tokens: Math.sin
sig: Math.sin(radians) -> fixed
tip: Sine of an angle in radians.
order: 12
ns: Math
member: sin
---

Returns the sine of <code>radians</code> as a <code>fixed</code> in <code>-1.0</code>..<code>1.0</code>. It is table-driven (a 256-entry Q16.16 sine table with linear interpolation) so it is fast and fully deterministic. Angles wrap, so any value works — no need to reduce into a range first. Pair it with <code>Math.cos</code> to turn an angle into a direction.

```ludic
program Demo {
  handler Step phase Update {
    let y = center_y + Math.sin(angle) * radius
  }
}
```
