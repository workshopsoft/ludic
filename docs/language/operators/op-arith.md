---
id: op-arith
name: Arithmetic
category: operators
kind: operator
sig: +  -  *  /  %
tip: Add, subtract, multiply, integer-divide, and remainder — on int and fixed.
order: 0
---

The arithmetic operators are `+` (add), `-` (subtract), `*` (multiply), `/` (divide), and `%` (remainder). On `int` values `/` is integer division that truncates and `%` gives the remainder — handy for wrapping a value or testing a period, as in `elapsed_frames % 30 == 0`. On `fixed` values the same symbols do fixed-point math (multiply and divide are scaled), and mixing an `int` with a `fixed` promotes the `int`. `*`, `/`, and `%` bind tighter than `+` and `-`, so `column * TILE_SIZE + 1` groups as expected.

```ludic
let pixel_x: int = column * TILE_SIZE + 1
let is_even_row: bool = row % 2 == 0
let average: int = (current_health + maximum_health) / 2
```
