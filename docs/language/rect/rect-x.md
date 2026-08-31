---
id: rect-x
name: Rect.x
category: rect
kind: namespace-method
tokens: Rect.x
sig: Rect.x(r) -> fixed
tip: The left edge (x position).
order: 1
ns: Rect
member: x
---

Reads the left edge — the <code>x</code> position of the rectangle's top-left corner.

```ludic
program Demo {
  handler Step phase Update {
    let left = Rect.x(hud)
  }
}
```
