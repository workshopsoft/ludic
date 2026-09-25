---
id: type-int
name: int
category: types
kind: type
tokens: int
sig: int
tip: The default 32-bit signed integer — also how colors, keys, and tiles are carried.
order: 0
---

`int` is a 32-bit signed integer and the default numeric type in Ludic: a literal like `42` or a hex literal like `0x1E90FF` is an `int`. It does far more than counting — colors are `int` hex values, the key from `Input.key()` is an `int` character code, and a tile from `Map.tile` is an `int`. Arithmetic (`+ - * / %`), comparison, and the bitwise operators all work on it, and it is the natural type for a `score`, a `column`, or an `elapsed_frames` counter. When you need fractions, reach for `fixed` and convert with `fx` / `flr`.

```ludic
let score: int = 0
const GRID_WIDTH: int = 20
let next_column: int = Random.range(low: 0, high: GRID_WIDTH - 1)
let next_score: int = score + 1
```
