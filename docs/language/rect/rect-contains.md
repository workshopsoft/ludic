---
id: rect-contains
name: Rect.contains
category: rect
kind: namespace-method
tokens: Rect.contains
sig: Rect.contains(r, px, py) -> bool
tip: True when the point is inside.
order: 8
ns: Rect
member: contains
---

Tests whether the point <code>(px, py)</code> falls inside the rectangle. The left and top edges are inclusive; the right and bottom edges are exclusive, so adjacent rectangles tile without overlap. The classic use is a mouse-in-button hit test.

```ludic
program Demo {
  handler Step phase Update {
    if Rect.contains(button, mx, my) { press() }
  }
}
```
