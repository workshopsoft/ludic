---
id: math-tan
name: Math.tan
category: math
kind: namespace-method
tokens: Math.tan
sig: Math.tan(radians) -> fixed
tip: Tangent of an angle in radians.
order: 14
ns: Math
member: tan
---

Returns the tangent of <code>radians</code>, computed as <code>Math.sin(radians) / Math.cos(radians)</code> in fixed-point. Near odd multiples of <code>pi/2</code> the cosine approaches zero and the result grows without bound, so guard those angles. For most gameplay, <code>Math.sin</code>/<code>Math.cos</code> are what you want; <code>tan</code> is here for slopes and field-of-view math.

```ludic
program Demo {
  handler Step phase Update {
    let slope = Math.tan(pitch)
  }
}
```
