---
id: input-pad_connected
name: Input.pad_connected
category: input
kind: namespace-method
tokens: Input.pad_connected
sig: Input.pad_connected(pad) -> bool
tip: Is a gamepad connected?
order: 23
ns: Input
member: pad_connected
---

Returns whether gamepad <code>pad</code> (0..3) is connected. Fed by <a href="input-set_pad.html"><code>Input.set_pad</code></a> (and, where a platform gamepad binding is present, by the device); lets a game show a "controller connected" prompt.

```ludic
program Demo {
  entry {
    Input.set_pad(0, true, 0, 0.0, 0.0, 0.0, 0.0)
    if Input.pad_connected(0) { print(1) }
  }
}
```
