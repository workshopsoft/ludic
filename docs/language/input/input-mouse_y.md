---
id: input-mouse_y
name: Input.mouse_y
category: input
kind: namespace-method
tokens: Input.mouse_y
sig: Input.mouse_y() -> int
tip: The mouse y position this frame.
order: 17
ns: Input
member: mouse_y
---

The mouse's y position this frame — fed by the window when windowed, or by <a href="input-set_mouse.html"><code>Input.set_mouse</code></a> otherwise.

```ludic
program Demo {
  entry {
    Input.set_mouse(10, 20, 0, 0)
    Input.poll()
    print(Input.mouse_y())
  }
}
```
