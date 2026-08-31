---
id: input-mouse_down
name: Input.mouse_down
category: input
kind: namespace-method
tokens: Input.mouse_down
sig: Input.mouse_down(button) -> bool
tip: Is a mouse button held?
order: 20
ns: Input
member: mouse_down
---

Returns whether a mouse button is held this frame — button <code>0</code> left, <code>1</code> right, <code>2</code> middle/other.

```ludic
program Demo {
  entry {
    Input.set_mouse(0, 0, 1, 0)
    Input.poll()
    if Input.mouse_down(0) { print(1) }
  }
}
```
