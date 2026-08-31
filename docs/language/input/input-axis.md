---
id: input-axis
name: Input.axis
category: input
kind: namespace-method
tokens: Input.axis
sig: Input.axis(neg, pos) -> fixed
tip: A -1..+1 axis from two keys.
order: 13
ns: Input
member: axis
---

Returns a digital axis from two keys: <code>+1.0</code> when the positive key is held, <code>-1.0</code> when the negative one is, <code>0</code> otherwise (both or neither). The building block for keyboard movement; a gamepad stick feeds the analog value through the same read.

```ludic
program Demo {
  entry {
    Input.press('d')
    Input.poll()
    print(Math.round(Input.axis('a', 'd')))
  }
}
```
