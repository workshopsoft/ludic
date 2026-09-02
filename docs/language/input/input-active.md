---
id: input-active
name: Input.active
category: input
kind: namespace-method
tokens: Input.active
sig: Input.active(action: str) -> bool
tip: Is a named action active right now (any bound key held, or pad button down)?
order: 33
ns: Input
member: active
---

Returns whether a named action is active this frame, reading the whole <a href="input-key_down.html">device layer</a>: true if any of the action's bound keyboard keys is in the multi-key held-set <em>or</em> any bound gamepad button is down on pad 0. Unlike <a href="input-down.html"><code>Input.down</code></a> (which reads only the single per-frame key), this sees simultaneous holds (move <em>and</em> jump) and is device-agnostic. The frame loop commits the device layer automatically, so it reads live without a manual <a href="input-poll.html"><code>Input.poll</code></a>.

```ludic
program Active {
  entry {
    Input.action("left", 'a')
    if Input.active("left") { print(1) }
  }
}
```
