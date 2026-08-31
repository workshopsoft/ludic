---
id: input-set_mouse
name: Input.set_mouse
category: input
kind: namespace-method
tokens: Input.set_mouse
sig: Input.set_mouse(x, y, buttons, wheel)
tip: Inject the mouse state (headless / AI / testing).
order: 22
ns: Input
member: set_mouse
---

Injects the whole mouse state: position <code>x</code>/<code>y</code>, a <code>buttons</code> bitmask (bit 0 left, 1 right, 2 middle), and this frame's <code>wheel</code> delta. The mouse counterpart to <a href="input-press.html"><code>Input.press</code></a> — for headless runs, AI, replays, or network-fed cursors.

```ludic
program Demo {
  entry {
    Input.set_mouse(64, 32, 1, 0)
    Input.poll()
    print(Input.mouse_x())
  }
}
```
