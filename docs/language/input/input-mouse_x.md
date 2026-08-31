---
id: input-mouse_x
name: Input.mouse_x
category: input
kind: namespace-method
tokens: Input.mouse_x
sig: Input.mouse_x() -> int
tip: The mouse x position this frame.
order: 16
ns: Input
member: mouse_x
---

The mouse's x position this frame — fed by the window when windowed, or by <a href="input-set_mouse.html"><code>Input.set_mouse</code></a> otherwise.

```ludic
program Demo {
  entry {
    Input.set_mouse(10, 20, 0, 0)
    Input.poll()
    print(Input.mouse_x())
  }
}
```
