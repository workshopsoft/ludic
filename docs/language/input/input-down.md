---
id: input-down
name: Input.down
category: input
kind: namespace-method
tokens: Input.down
sig: Input.down(action: str) -> bool
tip: Is a named action held on the frame last polled?
order: 4
ns: Input
member: down
---

Returns whether a named action is <em>held</em> on the frame last read by <a href="input-poll.html"><code>Input.poll</code></a> — true when the polled key is one of the keys bound to the action. Use it for continuous input (move while held); for a one-shot press use <a href="input-pressed.html"><code>Input.pressed</code></a>. Reading an action rather than a key is what lets the same handler serve any binding.

```ludic
program Held {
  entry {
    Input.bind("up", 'w')
    Input.poll()
    if Input.down("up") { print(1) }
  }
}
```
