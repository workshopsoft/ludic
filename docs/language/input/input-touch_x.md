---
id: input-touch_x
name: Input.touch_x
category: input
kind: namespace-method
tokens: Input.touch_x
sig: Input.touch_x(index) -> int
tip: The x of a touch point.
order: 28
ns: Input
member: touch_x
---

The x position of touch point <code>index</code> (0..7). Pair with <a href="input-touch_y.html"><code>Input.touch_y</code></a> and <a href="input-touch_count.html"><code>Input.touch_count</code></a> for multi-touch.

```ludic
program Demo {
  entry {
    Input.set_touch(0, 100, 200, true)
    print(Input.touch_x(0))
  }
}
```
