---
id: input-bind_pad
name: Input.bind_pad
category: input
kind: namespace-method
tokens: Input.bind_pad
sig: Input.bind_pad(action: str, button: int) -> void
tip: Also fire a named action from a gamepad button (device-agnostic).
order: 32
ns: Input
member: bind_pad
---

Maps a gamepad <code>button</code> (on pad 0) to a named action, so the action fires from the keyboard <em>or</em> the pad. The same action can carry both keyboard keys (<a href="input-bind.html"><code>Input.bind</code></a> / <a href="input-action.html"><code>Input.action</code></a>) and pad buttons; <a href="input-active.html"><code>Input.active</code></a> and its edges fire on either device — one action, any input.

```ludic
program Pad {
  entry {
    Input.action("fire", 'j')
    Input.bind_pad("fire", 0)
    if Input.active("fire") { print(1) }
  }
}
```
