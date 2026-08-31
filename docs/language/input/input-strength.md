---
id: input-strength
name: Input.strength
category: input
kind: namespace-method
tokens: Input.strength
sig: Input.strength(action) -> fixed
tip: 0..1 strength of a named action.
order: 15
ns: Input
member: strength
---

Returns the <code>0.0..1.0</code> strength of a named <a href="input-bind.html">action</a> — <code>1.0</code> when any bound key is held, <code>0</code> otherwise for keys (digital), and the analog magnitude when a gamepad feeds the action. Lets analog and digital sources share one read.

```ludic
program Demo {
  entry {
    Input.bind("gas", 'w')
    Input.press('w')
    Input.poll()
    print(Math.round(Input.strength("gas")))
  }
}
```
