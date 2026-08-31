---
id: rect-y
name: Rect.y
category: rect
kind: namespace-method
tokens: Rect.y
sig: Rect.y(r) -> fixed
tip: The top edge (y position).
order: 2
ns: Rect
member: y
---

Reads the top edge — the <code>y</code> position of the rectangle's top-left corner.

```ludic
program Demo {
  handler Step phase Update {
    let top = Rect.y(hud)
  }
}
```
