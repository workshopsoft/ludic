---
id: fx-sparks
name: Fx.sparks
category: fx
kind: namespace-method
tokens: Fx.sparks
sig: Fx.sparks(x: px, y: px, color: c, count: n)
tip: A burst of sparks flying out of a point.
order: 1
ns: Fx
member: sparks
---

Spawns <code>count</code> sparks at (x, y), each with a random velocity of up to 3px per frame on each axis and a lifetime of 18 to 26 frames; they are drawn as 1 to 3 pixel squares in <code>color</code>.

```ludic
# doc-check: skip — illustrative
@On(Died) handler Burst { Fx.sparks(x: center(e).x, y: center(e).y, color: Color.Crimson, count: 10) }
```
