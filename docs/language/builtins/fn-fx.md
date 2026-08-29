---
id: fn-fx
name: fx
category: builtins
kind: builtin
tokens: fx
sig: fx(n) -> fixed
tip: Lift an integer into a Q16.16 fixed-point value.
order: 50
---

Converts an integer into a <code>fixed</code> value (Ludic's Q16.16 fixed-point type), so it can take part in fractional arithmetic. Ludic has no floating point; <code>fixed</code> is how you carry sub-pixel precision for smooth movement and physics-like accumulation. Use <code>fx</code> when you need to combine an <code>int</code> with fixed-point values or divide to get a fraction — for example <code>fx(1) / fx(4)</code> is <code>0.25</code>. Convert back to a whole number for drawing with <code>flr</code>.

Parameters:
- `n` — the integer to lift into fixed-point

```ludic
program SmoothAccumulate {
  handler ComputeStep phase Start {
    let full_speed = fx(3)
    let half_speed = full_speed / fx(2)
    let two_steps = half_speed + half_speed
    print(flr(two_steps))
  }
}
```
