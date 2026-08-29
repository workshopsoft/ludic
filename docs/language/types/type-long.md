---
id: type-long
name: long
category: types
kind: type
tokens: long
sig: long
tip: A 64-bit signed integer for values that overflow a 32-bit int.
order: 1
---

`long` is a 64-bit signed integer — reach for it when a value would overflow the 32-bit `int`: a 64-bit hash or content id, an accumulated playtime in milliseconds, a large score or currency total, packed bit flags. Arithmetic (`+ - * / %`), comparison, and the bitwise operators all work on it, and mixing an `int` with a `long` promotes the `int` to 64 bits automatically — so `big * count` where `big` is a `long` computes in 64 bits and does not overflow. `print` and `str` render all its digits.

One limit to know: a numeric *literal* is still parsed as a 32-bit `int`, so build large values by widening — assign a smaller literal into a `long` and compute from there (`let m: long = 1000000` then `m * m`) rather than writing a 10-digit literal directly.

```ludic
let big: long = 1000000
var area: long = big * big        # 10^12, computed in 64 bits
var total: long = area + 1
var doubled: long = area * 2
```
