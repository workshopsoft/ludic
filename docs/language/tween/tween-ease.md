---
id: tween-ease
name: Tween.ease
category: tween
kind: namespace-method
tokens: Tween.ease
sig: Tween.ease(t, mode) -> fixed
tip: Shape a 0..1 amount through an easing curve chosen by a literal mode.
order: 5
ns: Tween
member: ease
---

Shapes a normalized amount <code>t</code> (<code>0.0</code>..<code>1.0</code>) through one of the engine's easing curves and returns the eased <code>fixed</code>. <code>mode</code> must be a literal integer selecting the curve — the same curves as the <a href="ease"><code>Ease</code></a> namespace:

- `0` — linear
- `1` — ease-in (quadratic)
- `2` — ease-out (quadratic)
- `3` — smooth ease-in-out
- `4` — ease-in-back (overshoots below 0)
- `5` — ease-out-elastic (springy settle)
- `6` — ease-out-bounce

Parameters:
- `t` — the amount to shape (a `fixed` in 0..1, e.g. from <a href="tween-progress"><code>Tween.progress</code></a>)
- `mode` — a literal `int` 0..6 selecting the curve

```ludic
program Demo {
  handler Run phase Update {
    let t = Tween.progress(fixed(1), fixed(2))
    let e = Tween.ease(t, 4)          # ease-in-back
    let x = Tween.round(0, 200, e)
    print(x)
  }
}
```
