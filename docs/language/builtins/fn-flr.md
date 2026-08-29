---
id: fn-flr
name: flr
category: builtins
kind: builtin
tokens: flr
sig: flr(x) -> int
tip: Floor a fixed-point value down to the nearest integer.
order: 50
---

Converts a <code>fixed</code> (Q16.16) value back to an <code>int</code> by discarding the fractional part, rounding toward negative infinity. It is the counterpart to <code>fx</code>: you accumulate motion in fixed-point for sub-pixel smoothness, then <code>flr</code> the result to get the whole-pixel column or row to draw at. Because it floors rather than rounds, <code>flr(fx(3) / fx(2))</code> is <code>1</code>, not <code>2</code>. Use it wherever a fixed value must become an integer coordinate, count, or index.

Parameters:
- `x` — the fixed-point value to floor

```ludic
program FixedToPixels {
  const TILE_SIZE: int = 16

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    let smooth_column = fx(5) + fx(1) / fx(2)
    let pixel_x = flr(smooth_column) * TILE_SIZE
    Screen.fill_rectangle(x: pixel_x, y: 32, width: TILE_SIZE, height: TILE_SIZE, color: Color.LimeGreen)
    Screen.show()
  }
}
```
