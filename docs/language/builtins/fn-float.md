---
id: fn-float
name: float
category: builtins
kind: builtin
tokens: float double
sig: float(x) -> float / double(x) -> double
tip: Convert any number to a float (or double).
order: 51
---

Converts an <code>int</code>, <code>long</code>, <code>fixed</code>, <code>float</code> or <code>double</code> to a <code>float</code> (or, with <code>double(x)</code>, to a <code>double</code>). It is the one conversion that crosses from fixed-point to floating point: `float(fixed(1)) / 4.0` is <code>0.25</code>. A decimal literal converts exactly, so `float(0.1)` is the nearest float to 0.1, not the nearest Q16.16 value.

Parameters:
- `x` — the number to convert

```ludic
program Convert {
  entry {
    let half = fixed(1) / 2
    print(float(half) * 3.0)           # 1.5
    print(double(7) / 2)               # 3.5
  }
}
```
