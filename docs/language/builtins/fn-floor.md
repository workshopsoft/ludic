---
id: fn-floor
name: floor
category: builtins
kind: builtin
tokens: floor
sig: floor(x) -> int
tip: Floor a fixed-point value down to the nearest integer.
order: 50
---

Converts a <code>fixed</code> (Q16.16) value back to an <code>int</code> by discarding the fractional part, rounding toward negative infinity. It is the counterpart to <code>fx</code>: you accumulate motion in fixed-point for sub-pixel smoothness, then <code>floor</code> the result to get the whole-pixel column or row to draw at. Because it floors rather than rounds, <code>floor(fixed(3) / fixed(2))</code> is <code>1</code>, not <code>2</code>. Use it wherever a fixed value must become an integer coordinate, count, or index.

Parameters:
- `x` — the fixed-point value to floor

```ludic
program FixedToPixels {
  const TILE_SIZE: int = 16

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    let smooth_column = fixed(5) + fixed(1) / fixed(2)
    let pixel_x = floor(smooth_column) * TILE_SIZE
    Screen.fill_rectangle(x: pixel_x, y: 32, width: TILE_SIZE, height: TILE_SIZE, color: Color.LimeGreen)
    Screen.show()
  }
}
```
