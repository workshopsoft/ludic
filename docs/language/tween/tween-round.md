---
id: tween-round
name: Tween.round
category: tween
kind: namespace-method
tokens: Tween.round
sig: Tween.round(from, to, t) -> int
tip: Linear blend of two ints by amount t, rounded to the nearest int.
order: 7
ns: Tween
member: round
---

Interpolates two <code>int</code> endpoints by amount <code>t</code> and rounds to the nearest integer (half up): <code>from + round((to - from) * t)</code>. The go-to for tweening a pixel position, a channel byte, or any integer field. Combine with <a href="tween-ease"><code>Tween.ease</code></a> for shaped motion.

Parameters:
- `from` — the value at `t = 0` (an `int`)
- `to` — the value at `t = 1` (an `int`)
- `t` — the blend amount (a `fixed`, usually 0..1)

```ludic
program Demo {
  property Slide { timer: fixed = 0.0 }
  model Card { Slide }
  handler Run phase Update {
    Slide.timer = Slide.timer + Time.delta()
    let t = Tween.progress(Slide.timer, fixed(1))
    let x = Tween.round(0, 320, Tween.ease(t, 2))
    print(x)
  }
}
```
