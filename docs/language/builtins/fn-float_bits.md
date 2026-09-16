---
id: fn-float_bits
name: float_bits
category: builtins
kind: builtin
tokens: float_bits float_from_bits double_bits double_from_bits
sig: float_bits(x) -> int / float_from_bits(bits) -> float
tip: A float's IEEE bit pattern as an int, and back.
order: 53
---

<code>float_bits(x)</code> returns the 32 bits of a <code>float</code> as an <code>int</code>, and <code>float_from_bits(bits)</code> reads them back. <code>double_bits</code> / <code>double_from_bits</code> do the same for a <code>double</code> with a <code>long</code>. Use them where a float has to travel as raw data: a file format, a network packet, or a <code>words</code> buffer shared with code that still stores bit patterns.

Parameters:
- `x` — the float to encode (`float_bits`), or the bits to decode (`float_from_bits`)

```ludic
program Bits {
  entry {
    print(float_bits(1.0))             # 1065353216 (0x3F800000)
    print(float_from_bits(0x40000000)) # 2.0
  }
}
```
