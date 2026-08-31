---
id: rect-right
name: Rect.right
category: rect
kind: namespace-method
tokens: Rect.right
sig: Rect.right(r) -> fixed
tip: The right edge, x + w.
order: 5
ns: Rect
member: right
---

Returns the right edge, <code>x + w</code> — the x coordinate just past the rectangle. Handy for anchoring something to a box's right side.

```ludic
program Demo {
  handler Step phase Update {
    let edge = Rect.right(hud)
  }
}
```
