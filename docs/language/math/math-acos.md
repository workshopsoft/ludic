---
id: math-acos
name: Math.acos
category: math
kind: namespace-method
tokens: Math.acos
sig: Math.acos(x) -> fixed
tip: The arccosine of a value, in radians.
order: 28
ns: Math
member: acos
---

Returns the angle in radians whose cosine is <code>x</code>, in <code>0</code>..<code>pi</code>. The input should be in <code>-1.0</code>..<code>1.0</code>. Handy for recovering the angle between two normalized directions from their dot product.

```ludic
program Demo {
  handler Step phase Update {
    let between = Math.acos(dot)
  }
}
```
