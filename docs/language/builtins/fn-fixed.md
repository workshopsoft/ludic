---
id: fn-fixed
name: fixed
category: builtins
kind: builtin
tokens: fixed
sig: fixed(x) -> fixed
tip: Convert an int (or a float) into a Q16.16 fixed-point value.
order: 50
---

Converts an integer into a <code>fixed</code> value (Ludic's Q16.16 fixed-point type), so it can take part in fractional arithmetic. <code>fixed</code> is how you carry deterministic sub-pixel precision for smooth movement and physics-like accumulation; a <code>float</code> or <code>double</code> converts too, truncated toward zero to Q16.16. Use <code>fixed</code> when you need to combine an <code>int</code> with fixed-point values or divide to get a fraction — for example <code>fixed(1) / fixed(4)</code> is <code>0.25</code>. Convert back to a whole number for drawing with <code>flr</code>.

Parameters:
- `x` — the integer (or float) to convert

```ludic
program SmoothAccumulate {
  handler ComputeStep phase Start {
    let full_speed = fixed(3)
    let half_speed = full_speed / fixed(2)
    let two_steps = half_speed + half_speed
    print(floor(two_steps))
  }
}
```
