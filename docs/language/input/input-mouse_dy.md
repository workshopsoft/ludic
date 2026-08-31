---
id: input-mouse_dy
name: Input.mouse_dy
category: input
kind: namespace-method
tokens: Input.mouse_dy
sig: Input.mouse_dy() -> int
tip: Mouse y movement since the last poll.
order: 19
ns: Input
member: mouse_dy
---

The change in the mouse's y since the previous <a href="input-poll.html"><code>Input.poll</code></a> — the vertical companion to <a href="input-mouse_dx.html"><code>Input.mouse_dx</code></a>.

```ludic
program Demo {
  entry {
    Input.set_mouse(0, 10, 0, 0)
    Input.poll()
    Input.set_mouse(0, 18, 0, 0)
    Input.poll()
    print(Input.mouse_dy())
  }
}
```
