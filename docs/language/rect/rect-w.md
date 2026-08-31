---
id: rect-w
name: Rect.w
category: rect
kind: namespace-method
tokens: Rect.w
sig: Rect.w(r) -> fixed
tip: The width.
order: 3
ns: Rect
member: w
---

Reads the width of the rectangle.

```ludic
program Demo {
  handler Step phase Update {
    let width = Rect.w(hud)
  }
}
```
