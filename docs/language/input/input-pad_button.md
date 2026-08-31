---
id: input-pad_button
name: Input.pad_button
category: input
kind: namespace-method
tokens: Input.pad_button
sig: Input.pad_button(pad, button) -> bool
tip: Is a gamepad button held?
order: 24
ns: Input
member: pad_button
---

Returns whether <code>button</code> on gamepad <code>pad</code> is held — a bit in the pad's button mask, in the SDL standard order (A/B/X/Y, bumpers, start, …).

```ludic
program Demo {
  entry {
    Input.set_pad(0, true, 1, 0.0, 0.0, 0.0, 0.0)
    if Input.pad_button(0, 0) { print(1) }
  }
}
```
