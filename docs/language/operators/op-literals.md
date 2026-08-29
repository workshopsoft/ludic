---
id: op-literals
name: Literals
category: operators
kind: operator
sig: 42   0x1E90FF   'w'   "text"   true   null
tip: Integer, hex, character, string, boolean, and null-pointer literals.
order: 8
---

Literals are the fixed values you write directly in source. `42` is a decimal `int` and `0x1E90FF` is a hex `int` — hex is how colors are written, so a raw color is just an integer. A number with a decimal point (`1.5`) is a `fixed`. `'w'` is a character literal, an `int` code point handy for comparing against `Input.key()`. `"text"` is a `str`, `true` / `false` are `bool`s, and `null` is the null-pointer literal used to test an unset record, slice, or `ptr` field.

```ludic
let sky_color: int = 0x1E90FF
let banner: str = "GAME OVER"
if Input.key() == 'w' { row = row - 1 }
if next_segment == null { is_tail = true }
```
