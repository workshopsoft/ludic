---
id: collision-rect_circle
name: Collision.rect_circle
category: collision
kind: namespace-method
tokens: Collision.rect_circle
sig: Collision.rect_circle(rx, ry, rw, rh, cx, cy, cr) -> bool
tip: Does a rectangle overlap a circle?
order: 3
ns: Collision
member: rect_circle
---

Returns <code>true</code> when the rectangle <code>(rx, ry, rw, rh)</code> overlaps the circle centred at <code>(cx, cy)</code> with radius <code>cr</code>. It finds the point on the rectangle nearest the circle's centre and checks whether it falls within the radius — the correct test for a round actor against a blocky tile.

```ludic
program Demo {
  handler Step phase Update {
    if Collision.rect_circle(tx, ty, 16, 16, bx, by, 6) { block() }
  }
}
```
