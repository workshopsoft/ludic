---
id: type-fixed
name: fixed
category: types
kind: type
tokens: fixed
sig: fixed
tip: Q16.16 fixed-point for deterministic fractional math — no floats.
order: 1
---

`fixed` is Q16.16 fixed-point: a fractional number stored in 32 bits, giving you decimals without floating-point. Ludic uses it precisely because it is <b>deterministic</b> — the same computation gives the same bits on every machine, which is what a reproducible simulation and lockstep networking need. A literal with a decimal point (`1.5`) is a `fixed`; arithmetic on two `fixed` values does fixed-point multiply/divide, and mixing an `int` with a `fixed` promotes the `int`. Lift an `int` in with `fx(value)` and take the floor back out with `flr(value)`.

```ludic
const GRAVITY: fixed = 0.5
var velocity_y: fixed = fx(0)
var next_velocity: fixed = velocity_y + GRAVITY
var pixel_row: int = flr(next_velocity)
```
