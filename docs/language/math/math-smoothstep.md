---
id: math-smoothstep
name: Math.smoothstep
category: math
kind: namespace-method
tokens: Math.smoothstep
sig: Math.smoothstep(e0, e1, x) -> fixed
tip: A smooth 0..1 ramp between two edges.
order: 25
ns: Math
member: smoothstep
---

Returns <code>0.0</code> when <code>x</code> is at or below <code>e0</code>, <code>1.0</code> at or above <code>e1</code>, and a smooth S-curve (ease-in and ease-out) in between — the classic <code>t*t*(3 - 2t)</code> Hermite ramp. Use it for fades, dissolves, and easing a normalized amount before feeding it to <code>Math.lerp</code>, when a straight linear ramp looks too abrupt.

```ludic
program Demo {
  handler Step phase Update {
    let a = Math.smoothstep(0.0, 1.0, fade_t)
  }
}
```
