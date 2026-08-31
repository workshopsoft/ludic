---
id: input-key_down
name: Input.key_down
category: input
kind: namespace-method
tokens: Input.key_down
sig: Input.key_down(key) -> bool
tip: Is a physical key held this frame?
order: 8
ns: Input
member: key_down
---

Returns whether a physical <code>key</code> is held this frame — from the platform when windowed, from the polled key when headless, and from <a href="input-press.html"><code>Input.press</code></a> injection on any target. Unlike the single-key <a href="input-down.html"><code>Input.down</code></a>, several keys can be held at once (move left <em>and</em> jump).

```ludic
program Demo {
  entry {
    Input.press('a')
    Input.poll()
    if Input.key_down('a') { print(1) }
  }
}
```
