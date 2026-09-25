---
id: math-inverse_lerp
name: Math.inverse_lerp
category: math
kind: namespace-method
tokens: Math.inverse_lerp
sig: Math.inverse_lerp(a, b, v) -> fixed
tip: Find where a value sits between two endpoints as a 0..1 fraction.
order: 9
ns: Math
member: inverse_lerp
---

The inverse of <code>Math.lerp</code>: given endpoints <code>a</code> and <code>b</code> and a value <code>v</code>, it returns the fraction <code>(v - a) / (b - a)</code> — <code>0.0</code> when <code>v</code> equals <code>a</code>, <code>1.0</code> when it equals <code>b</code>. Use it to turn a raw quantity into a normalized amount: how full a health bar is, how far a timer has run, or the <code>t</code> to feed into another <code>Math.lerp</code>. The endpoints must differ, since equal ones would divide by zero.

Parameters:
- `a` — the endpoint that maps to `0.0`
- `b` — the endpoint that maps to `1.0`
- `v` — the value to locate between them

```ludic
program HealthFraction {
  const MAX_HP: fixed = 200.0

  let hp: fixed = 150.0

  handler Draw phase Render {
    let fraction = Math.inverse_lerp(0.0, MAX_HP, hp)   # 0.75
  }
}
```
