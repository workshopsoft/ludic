---
id: math-round
name: Math.round
category: math
kind: namespace-method
tokens: Math.round
sig: Math.round(x) -> int
tip: Round a fixed value to the nearest whole int.
order: 7
ns: Math
member: round
---

Takes a <code>fixed</code> value and returns the nearest <code>int</code>, with halves rounding up: <code>Math.round(2.5)</code> is <code>3</code> and <code>Math.round(2.4)</code> is <code>2</code>. Choose it over <code>Math.floor</code> when you want the closest whole value rather than always the lower one — snapping a smoothly-moving sprite to a pixel, or reporting a fractional total as a clean number.

Parameters:
- `x` — the `fixed` value to round to nearest

```ludic
program SnapToPixel {
  var smooth_x: fixed = 10.5

  handler Draw phase Render {
    let px = Math.round(smooth_x)   # 11
  }
}
```
