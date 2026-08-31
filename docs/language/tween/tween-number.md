---
id: tween-number
name: Tween.number
category: tween
kind: namespace-method
tokens: Tween.number
sig: Tween.number(from, to, t) -> fixed
tip: Linear blend of two fixeds by amount t.
order: 6
ns: Tween
member: number
---

Interpolates two <code>fixed</code> values: <code>from + (to - from) * t</code>. Feed it an eased <code>t</code> from <a href="tween-ease"><code>Tween.ease</code></a> to tween any fractional quantity — an alpha, a scale, a fixed-point position.

Parameters:
- `from` — the value at `t = 0` (a `fixed`)
- `to` — the value at `t = 1` (a `fixed`)
- `t` — the blend amount (a `fixed`, usually 0..1)

```ludic
program Demo {
  handler Run phase Update {
    let t = Tween.progress(fixed(1), fixed(2))
    let scale = Tween.number(fixed(1), fixed(2), Tween.ease(t, 2))
    print(scale)
  }
}
```
