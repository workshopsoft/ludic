---
id: input-touch_count
name: Input.touch_count
category: input
kind: namespace-method
tokens: Input.touch_count
sig: Input.touch_count() -> int
tip: How many touch points are active?
order: 27
ns: Input
member: touch_count
---

Returns how many touch points are currently active (0..8). Iterate them with <a href="input-touch_x.html"><code>Input.touch_x</code></a> / <a href="input-touch_y.html"><code>Input.touch_y</code></a>.

```ludic
program Demo {
  entry {
    Input.set_touch(0, 10, 20, true)
    Input.set_touch(1, 30, 40, true)
    print(Input.touch_count())
  }
}
```
