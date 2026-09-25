---
id: math-abs
name: Math.abs
category: math
kind: namespace-method
tokens: Math.abs
sig: Math.abs(x) -> int
tip: The magnitude of a value, dropping its sign.
order: 2
ns: Math
member: abs
---

Returns the absolute value of <code>x</code> — its distance from zero, always non-negative. It preserves the type of its argument, so <code>Math.abs</code> of a <code>fixed</code> stays <code>fixed</code>. Reach for it when you care about how far apart two things are regardless of direction, such as the gap between a target and current position, or the speed behind a signed velocity. The bare form <code>abs(x)</code> is kept as a convenience alias.

Parameters:
- `x` — the value whose magnitude you want

```ludic
program ChaseDistance {
  let target: int = 40
  let here: int = 12

  handler Report phase Update {
    let gap = Math.abs(target - here)   # 28, regardless of which is larger
  }
}
```
