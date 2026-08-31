---
id: type-rect
name: Rect
category: types
kind: type
tokens: Rect
sig: Rect
tip: A rectangle — position (x, y) and size (w, h), copied by value.
order: 15
---

<code>Rect</code> is an axis-aligned rectangle: four Q16.16 <code>fixed</code> components — the top-left corner <code>(x, y)</code> and the size <code>(w, h)</code> — packed into a single value that is copied by value and never heap-allocates. It is the natural type for HUD layout boxes, hitboxes, and camera or viewport regions. Build one with <code>Rect.make(x, y, w, h)</code>, read the parts with <code>Rect.x</code> / <code>Rect.y</code> / <code>Rect.w</code> / <code>Rect.h</code> (or the derived <code>Rect.right</code> / <code>Rect.bottom</code> / <code>Rect.center</code>), and test against it with <code>Rect.contains</code> for a point and <code>Rect.intersects</code> for overlap. Every operation is deterministic fixed-point, so results are bit-identical on every platform.

```ludic
program Demo {
  handler Step phase Update {
    let button: Rect = Rect.make(8.0, 8.0, 96.0, 16.0)
    if Rect.contains(button, mx, my) { press() }
  }
}
```
