---
id: math-posmod
name: Math.posmod
category: math
kind: namespace-method
tokens: Math.posmod
sig: Math.posmod(a, m) -> int
tip: Modulo that is always non-negative.
order: 20
ns: Math
member: posmod
---

Returns <code>a</code> modulo <code>m</code>, but always in the range <code>0</code>..<code>m-1</code> — unlike the <code>%</code> operator, which keeps the sign of <code>a</code> (so <code>-1 % 5</code> is <code>-1</code>, while <code>Math.posmod(-1, 5)</code> is <code>4</code>). It is what you want for wrapping indices and grid coordinates that can go negative.

```ludic
program Demo {
  handler Step phase Update {
    let col = Math.posmod(x, grid_width)   # never negative
  }
}
```
