---
id: math-min
name: Math.min
category: math
kind: namespace-method
tokens: Math.min
sig: Math.min(a, b) -> int
tip: The smaller of two values.
order: 0
ns: Math
member: min
---

Returns whichever of <code>a</code> and <code>b</code> is smaller. It works on plain <code>int</code> values and on <code>fixed</code> values alike — both are stored as signed 32-bit words, so the comparison keeps their order either way. Use it to cap a value at a ceiling, keep a cursor inside a list, or take the nearer of two distances. The bare form <code>min(a, b)</code> is kept as a convenience alias.

Parameters:
- `a` — the first value
- `b` — the second value

```ludic
program ClampScore {
  var score: int = 0

  handler AddPoint phase Update {
    score = Math.min(score + 1, 100)   # never climbs past 100
  }
}
```
