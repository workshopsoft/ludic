---
id: input-wheel
name: Input.wheel
category: input
kind: namespace-method
tokens: Input.wheel
sig: Input.wheel() -> int
tip: Scroll-wheel delta this frame.
order: 21
ns: Input
member: wheel
---

The scroll-wheel delta accumulated this frame — positive up, negative down, <code>0</code> when the wheel did not move. A per-frame delta, reset each <a href="input-poll.html"><code>Input.poll</code></a>.

```ludic
program Demo {
  entry {
    Input.set_mouse(0, 0, 0, 3)
    Input.poll()
    print(Input.wheel())
  }
}
```
