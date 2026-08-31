---
id: rect-intersects
name: Rect.intersects
category: rect
kind: namespace-method
tokens: Rect.intersects
sig: Rect.intersects(a, b) -> bool
tip: True when two rectangles overlap.
order: 9
ns: Rect
member: intersects
---

Tests whether two rectangles overlap (axis-aligned bounding-box test). Touching edges do not count as overlapping. This is the cheap broad-phase check before any finer collision work.

```ludic
program Demo {
  handler Step phase Update {
    if Rect.intersects(player, hazard) { hurt() }
  }
}
```
