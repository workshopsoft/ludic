---
id: op-range
name: Range
category: operators
kind: operator
sig: a .. b
tip: A half-open range for numeric for loops — from a up to but not including b.
order: 4
---

`a .. b` is a half-open numeric range used by the counting `for` loop: `for index in a .. b` walks `index` from `a` up to but <b>not including</b> `b`. This "up to but not including" convention makes lengths line up naturally — `0 .. len(route)` visits every element index of a slice, and `0 .. GRID_WIDTH` visits every column with no off-by-one. Both endpoints are `int` expressions, so a bound can be a `const`, a `var`, or any computed value. It is distinct from the string slice `text[start..end]`, which uses the same half-open idea for bytes.

```ludic
for row in 0 .. GRID_HEIGHT {
  for column in 0 .. GRID_WIDTH {
    Screen.put_pixel(x: column, y: row, color: Color.MidnightBlue)
  }
}
```
