---
id: type-double
name: double
category: types
kind: type
tokens: double
sig: double
tip: A 64-bit IEEE floating-point number for precise math.
order: 4
---

A <code>double</code> is an IEEE-754 double-precision number: about sixteen significant digits. Use it where a <code>float</code> loses precision — large world coordinates, accumulated time, geodesy — and convert to <code>float</code> at the boundary to the GPU.

It behaves like <code>float</code>: decimal literals take its type from context, <code>int</code> and <code>long</code> promote to it, and a <code>float</code> mixed with a <code>double</code> widens to <code>double</code>. Narrowing back is explicit: <code>float(d)</code>.

```ludic
program Precise {
  entry {
    let total: double = 0.1
    print(total + 0.2)                 # 0.30000000000000004
    let small: float = float(total)
    print(small)                       # 0.1
  }
}
```
