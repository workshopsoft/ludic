---
id: input-set_pad
name: Input.set_pad
category: input
kind: namespace-method
tokens: Input.set_pad
sig: Input.set_pad(pad, connected, buttons, lx, ly, rx, ry)
tip: Inject a gamepad's whole state.
order: 26
ns: Input
member: set_pad
---

Injects gamepad <code>pad</code>'s whole state: <code>connected</code>, a <code>buttons</code> bitmask, and the four stick axes (<code>lx</code>, <code>ly</code>, <code>rx</code>, <code>ry</code>) as <code>fixed</code> in <code>-1.0..+1.0</code>. A platform gamepad binding feeds the same state; until then this drives it from replays, AI, or the network.

```ludic
program Demo {
  entry {
    Input.set_pad(0, true, 5, 1.0, 0.0, 0.0, 0.0)
    if Input.pad_button(0, 2) { print(1) }
  }
}
```
