---
id: math-max
name: Math.max
category: math
kind: namespace-method
tokens: Math.max
sig: Math.max(a, b) -> int
tip: The larger of two values.
order: 1
ns: Math
member: max
---

Returns whichever of <code>a</code> and <code>b</code> is larger. Like <code>Math.min</code>, it works for both <code>int</code> and <code>fixed</code> operands. Use it to hold a value at a floor — for example keeping a countdown at zero instead of going negative, or a health bar from dropping below the minimum. The bare form <code>max(a, b)</code> is kept as a convenience alias.

Parameters:
- `a` — the first value
- `b` — the second value

```ludic
program Countdown {
  var timer: int = 60

  handler Tick phase Update {
    timer = Math.max(timer - 1, 0)   # stops at 0, never negative
  }
}
```
