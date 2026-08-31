---
id: input-key_pressed
name: Input.key_pressed
category: input
kind: namespace-method
tokens: Input.key_pressed
sig: Input.key_pressed(key) -> bool
tip: Did a key go down this frame (edge)?
order: 9
ns: Input
member: key_pressed
---

Returns whether a key went down <em>this</em> frame — held now, not held last frame. A clean rising edge for one-shot actions (fire, confirm), distinct from the continuous <a href="input-key_down.html"><code>Input.key_down</code></a>.

```ludic
program Demo {
  entry {
    Input.press(' ')
    Input.poll()
    if Input.key_pressed(' ') { print(1) }
  }
}
```
