---
id: math-log
name: Math.log
category: math
kind: namespace-method
tokens: Math.log
sig: Math.log(x) -> fixed
tip: The natural logarithm of x.
order: 30
ns: Math
member: log
---

Returns the natural logarithm <code>ln(x)</code> for <code>x &gt; 0</code>, computed in Q16.16 from a deterministic integer <code>log₂</code> (bit-scan for the exponent, a short series for the mantissa) scaled by <code>ln 2</code> — bit-identical on every platform. It is the inverse of <code>Math.exp</code>: reach for it to turn multiplicative growth into a straight line — score-to-level curves, logarithmic difficulty, decibel-style volume. Non-positive inputs are out of domain and saturate to a large negative value rather than returning a meaningful number.

```ludic
program Demo {
  handler Step phase Update {
    let level = Math.floor(Math.log(score))   # diminishing returns on score
  }
}
```
