---
id: rect-make
name: Rect.make
category: rect
kind: namespace-method
tokens: Rect.make
sig: Rect.make(x, y, w, h) -> Rect
tip: Build a rectangle from a corner and a size.
order: 0
ns: Rect
member: make
---

Builds a <code>Rect</code> from its top-left corner <code>(x, y)</code> and size <code>(w, h)</code>, all <code>fixed</code>. Read the parts back with <code>Rect.x</code> / <code>Rect.y</code> / <code>Rect.w</code> / <code>Rect.h</code>.

```ludic
program Demo {
  handler Step phase Update {
    let hud = Rect.make(8.0, 8.0, 96.0, 16.0)
  }
}
```
