---
id: rect-h
name: Rect.h
category: rect
kind: namespace-method
tokens: Rect.h
sig: Rect.h(r) -> fixed
tip: The height.
order: 4
ns: Rect
member: h
---

Reads the height of the rectangle.

```ludic
program Demo {
  handler Step phase Update {
    let height = Rect.h(hud)
  }
}
```
