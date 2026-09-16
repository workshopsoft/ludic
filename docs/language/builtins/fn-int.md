---
id: fn-int
name: int
category: builtins
kind: builtin
tokens: int long
sig: int(x) -> int / long(x) -> long
tip: Convert a number to a whole number, truncating toward zero.
order: 52
---

Converts a <code>float</code>, <code>double</code>, <code>fixed</code> or <code>long</code> to an <code>int</code> (or, with <code>long(x)</code>, to a <code>long</code>). Floating-point values truncate toward zero, as in C: `int(2.9)` is <code>2</code> and `int(-2.9)` is <code>-2</code>. A <code>fixed</code> value rounds down, like <code>floor</code>. For other rounding use <code>Math.floor</code>, <code>Math.ceil</code> or <code>Math.round</code>.

Parameters:
- `x` — the number to convert

```ludic
program Whole {
  entry {
    let pixels: float = 12.75
    print(int(pixels))                 # 12
    print(long(pixels * 1000.0))       # 12750
  }
}
```
