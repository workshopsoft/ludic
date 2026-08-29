---
id: kw-extern
name: extern
category: structure
kind: keyword
tokens: extern
sig: extern function name(a: T) -> R = "symbol"
tip: Bind a name to an external native symbol — the seam for platform and library calls.
order: 12
---

An <code>extern function</code> declares a function whose body lives outside Ludic and binds it to a native symbol resolved at link time. It is the seam through which Ludic reaches anything with a native interface — a system library, a math routine, or even another `.ludic` file compiled as a `module`. You write the Ludic signature you want to call and give the real symbol name after `=`; the linker connects them (pass `-L`/`-l` to `ludicc` to point at the library). Types must match the foreign ABI, so map each parameter and the return to the right Ludic type (`int`, `fixed`, `ptr`, …).

Parameters:
- `a` — a typed argument passed straight through to the foreign symbol

```ludic
program Physics {
  extern function c_hypot(a: fixed, b: fixed) -> fixed = "hypot_fx"

  property Velocity { delta_x: int = 0, delta_y: int = 0 }
  model Projectile { Velocity }

  handler MeasureSpeed phase Update {
    for (velocity) in query [Velocity, {Projectile}] {
      let speed = c_hypot(a: fx(velocity.delta_x), b: fx(velocity.delta_y))
      Screen.status(string(flr(speed)))
    }
  }
}
```
