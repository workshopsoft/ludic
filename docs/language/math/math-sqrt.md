---
id: math-sqrt
name: Math.sqrt
category: math
kind: namespace-method
tokens: Math.sqrt
sig: Math.sqrt(x) -> fixed
tip: The square root of a fixed value.
order: 11
ns: Math
member: sqrt
---

Returns the non-negative square root of <code>x</code>, computed in Q16.16 by a deterministic integer algorithm — so it is bit-identical on every platform, the same guarantee the rest of the runtime gives. Negative inputs return <code>0</code>. Use it for lengths and distances; when you have two legs of a right triangle reach for <code>Math.hypot</code>, and when you only need to compare magnitudes prefer the cheaper squared distance <code>Math.dist2</code>.

```ludic
program Demo {
  handler Step phase Update {
    let speed = Math.sqrt(vx * vx + vy * vy)
  }
}
```
