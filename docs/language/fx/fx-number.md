---
id: fx-number
name: Fx.number
category: fx
kind: namespace-method
tokens: Fx.number
sig: Fx.number(x: px, y: px, value: n, color: c)
tip: A number that floats up from a point and fades.
order: 2
ns: Fx
member: number
---

Shows <code>value</code> above (x, y) for 30 frames, rising one pixel every other frame — the damage number of every action game.

```ludic
# doc-check: skip — illustrative
@On(Damaged) handler ShowHit { Fx.number(x: center(target).x, y: center(target).y, value: amount, color: Color.Lemon) }
```
