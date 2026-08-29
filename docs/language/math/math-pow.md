---
id: math-pow
name: Math.pow
category: math
kind: namespace-method
tokens: Math.pow
sig: Math.pow(base, exp) -> fixed
tip: base raised to a fixed exponent.
order: 31
ns: Math
member: pow
---

Returns <code>base<sup>exp</sup></code> for <code>base &gt; 0</code> and any fixed <code>exp</code>, computed in Q16.16 as <code>2<sup>exp·log₂base</sup></code> — so non-integer exponents work (<code>Math.pow(x, 0.5)</code> is a square root, though <code>Math.sqrt</code> is cheaper and exact) and it stays bit-identical on every platform. Use it for gameplay curves that need a tunable exponent: damage falloff, easing shaped by a designer-set power, or compound-growth economies. Keep the result inside the fixed range (magnitudes below <code>32768</code>); combinations that exceed it saturate.

```ludic
program Demo {
  handler Step phase Update {
    let falloff = Math.pow(0.9, distance)   # each unit keeps 90% of the effect
  }
}
```
