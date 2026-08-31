---
id: input-rebind
name: Input.rebind
category: input
kind: namespace-method
tokens: Input.rebind
sig: Input.rebind(action: str, from: int, to: int) -> void
tip: Remap an action from one key to another at runtime (rebinding menus).
order: 2
ns: Input
member: rebind
---

Replaces the key <code>from</code> with <code>to</code> on a named action, at runtime — the primitive a "press a key to rebind" options screen is built on. A no-op if the action does not exist or is not bound to <code>from</code>. Because gameplay reads actions, not keys, a rebind takes effect immediately with no change to the game logic.

```ludic
program Rebinding {
  entry {
    Input.bind("jump", ' ')
    Input.rebind("jump", ' ', 'x')
    Input.poll()
    if Input.down("jump") { print(1) }
  }
}
```
