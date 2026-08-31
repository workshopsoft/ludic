---
id: rect-bottom
name: Rect.bottom
category: rect
kind: namespace-method
tokens: Rect.bottom
sig: Rect.bottom(r) -> fixed
tip: The bottom edge, y + h.
order: 6
ns: Rect
member: bottom
---

Returns the bottom edge, <code>y + h</code> — the y coordinate just below the rectangle.

```ludic
program Demo {
  handler Step phase Update {
    let base = Rect.bottom(hud)
  }
}
```
