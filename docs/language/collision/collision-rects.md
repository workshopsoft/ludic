---
id: collision-rects
name: Collision.rects
category: collision
kind: namespace-method
tokens: Collision.rects
sig: Collision.rects(ax, ay, aw, ah, bx, by, bw, bh) -> bool
tip: Do two rectangles overlap?
order: 0
ns: Collision
member: rects
---

Returns <code>true</code> when the axis-aligned rectangles <code>(ax, ay, aw, ah)</code> and <code>(bx, by, bw, bh)</code> overlap. Edges that merely touch do not count as overlapping. This is the standard broad-phase test for two hitboxes, tiles, or UI regions.

```ludic
program Demo {
  handler Step phase Update {
    if Collision.rects(px, py, 16, 16, ex, ey, 16, 16) { hit() }
  }
}
```
