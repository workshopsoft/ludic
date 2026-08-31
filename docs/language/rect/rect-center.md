---
id: rect-center
name: Rect.center
category: rect
kind: namespace-method
tokens: Rect.center
sig: Rect.center(r) -> Vector
tip: The center point as a Vector.
order: 7
ns: Rect
member: center
---

Returns the center point <code>(x + w/2, y + h/2)</code> as a <code>Vector</code> — the anchor you want when placing a label or spawning at the middle of a box.

```ludic
program Demo {
  handler Step phase Update {
    let mid = Rect.center(hud)
  }
}
```
