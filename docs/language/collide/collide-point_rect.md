---
id: collide-point_rect
name: Collide.point_rect
category: collide
kind: namespace-method
tokens: Collide.point_rect
sig: Collide.point_rect(px, py, rx, ry, rw, rh) -> bool
tip: Is a point inside a rectangle?
order: 1
ns: Collide
member: point_rect
---

Returns <code>true</code> when the point <code>(px, py)</code> lies within the rectangle <code>(rx, ry, rw, rh)</code> — inclusive on the top-left edge, exclusive on the bottom-right. Use it for mouse or touch hit-testing against a button or a world region.

```ludic
program Demo {
  handler Step phase Update {
    if Collide.point_rect(mx, my, bx, by, bw, bh) { press() }
  }
}
```
