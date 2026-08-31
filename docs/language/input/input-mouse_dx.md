---
id: input-mouse_dx
name: Input.mouse_dx
category: input
kind: namespace-method
tokens: Input.mouse_dx
sig: Input.mouse_dx() -> int
tip: Mouse x movement since the last poll.
order: 18
ns: Input
member: mouse_dx
---

The change in the mouse's x since the previous <a href="input-poll.html"><code>Input.poll</code></a> — the relative motion for dragging, panning, or a mouse-look camera.

```ludic
program Demo {
  entry {
    Input.set_mouse(10, 0, 0, 0)
    Input.poll()
    Input.set_mouse(15, 0, 0, 0)
    Input.poll()
    print(Input.mouse_dx())
  }
}
```
