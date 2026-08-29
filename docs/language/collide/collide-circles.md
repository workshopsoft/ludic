---
id: collide-circles
name: Collide.circles
category: collide
kind: namespace-method
tokens: Collide.circles
sig: Collide.circles(ax, ay, ar, bx, by, br) -> bool
tip: Do two circles overlap?
order: 2
ns: Collide
member: circles
---

Returns <code>true</code> when circles centred at <code>(ax, ay)</code> and <code>(bx, by)</code> with radii <code>ar</code> and <code>br</code> overlap — that is, when the distance between centres is at most <code>ar + br</code>. It compares squared distances internally, so there is no square root and no precision loss.

```ludic
program Demo {
  handler Step phase Update {
    if Collide.circles(px, py, 8, ex, ey, 8) { collide() }
  }
}
```
