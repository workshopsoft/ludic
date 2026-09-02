---
id: input-action
name: Input.action
category: input
kind: namespace-method
tokens: Input.action
sig: Input.action(action: str, key: int) -> void
tip: Register a default key binding for an action (kept if already bound).
order: 31
ns: Input
member: action
---

Registers a <em>default</em> keyboard binding: it binds <code>key</code> to the action only if the action has no key bound yet. Ship your defaults with <code>Input.action</code> in a Boot handler; a player's later <a href="input-rebind.html"><code>Input.rebind</code></a> (or a loaded key-map) is not clobbered, and re-running the defaults is idempotent. Combine with <a href="input-bind_pad.html"><code>Input.bind_pad</code></a> for a device-agnostic action, and read it with <a href="input-active.html"><code>Input.active</code></a>.

```ludic
program Defaults {
  entry {
    Input.action("jump", ' ')
    if Input.active("jump") { print(1) }
  }
}
```
