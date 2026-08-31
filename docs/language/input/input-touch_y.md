---
id: input-touch_y
name: Input.touch_y
category: input
kind: namespace-method
tokens: Input.touch_y
sig: Input.touch_y(index) -> int
tip: The y of a touch point.
order: 29
ns: Input
member: touch_y
---

The y position of touch point <code>index</code> (0..7) — the vertical companion to <a href="input-touch_x.html"><code>Input.touch_x</code></a>.

```ludic
program Demo {
  entry {
    Input.set_touch(0, 100, 200, true)
    print(Input.touch_y(0))
  }
}
```
