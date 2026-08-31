---
id: input-pad_axis
name: Input.pad_axis
category: input
kind: namespace-method
tokens: Input.pad_axis
sig: Input.pad_axis(pad, axis) -> fixed
tip: A gamepad analog axis, -1..+1.
order: 25
ns: Input
member: pad_axis
---

Returns a gamepad analog axis as a <code>fixed</code> in <code>-1.0..+1.0</code> — axis <code>0</code> left-stick x, <code>1</code> left-stick y, <code>2</code> right-stick x, <code>3</code> right-stick y. Apply your own deadzone near zero.

```ludic
program Demo {
  entry {
    Input.set_pad(0, true, 0, 1.0, 0.0, 0.0, 0.0)
    print(Math.round(Input.pad_axis(0, 0)))
  }
}
```
