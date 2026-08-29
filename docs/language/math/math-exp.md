---
id: math-exp
name: Math.exp
category: math
kind: namespace-method
tokens: Math.exp
sig: Math.exp(x) -> fixed
tip: e raised to the power x.
order: 29
ns: Math
member: exp
---

Returns <code>e<sup>x</sup></code> (the natural exponential), computed in Q16.16 as <code>2<sup>x·log₂e</sup></code> through a range-reduced integer polynomial — so it is bit-identical on every platform, the same guarantee the rest of the runtime gives. Pair it with <code>Math.log</code> for exponential decay and growth: cooldowns that ease off, difficulty ramps, or a value that relaxes toward a target. The result must land inside the fixed-point range (magnitudes below <code>32768</code>), so keep <code>x</code> under about <code>10</code>; larger exponents saturate.

```ludic
program Demo {
  handler Step phase Update {
    let remaining = Math.exp(0.0 - decay * elapsed)   # smooth decay 1 -> 0
  }
}
```
