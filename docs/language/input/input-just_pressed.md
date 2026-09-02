---
id: input-just_pressed
name: Input.just_pressed
category: input
kind: namespace-method
tokens: Input.just_pressed
sig: Input.just_pressed(action: str) -> bool
tip: Did a named action go active this frame (the deterministic on-press)?
order: 34
ns: Input
member: just_pressed
---

Returns whether a named action went active this frame — active now, not active last frame. This is the deterministic on-press edge over the device layer (keyboard or pad), the event-style "just pressed" without a callback: a handler polls it each frame and reacts. Pair with <a href="input-just_released.html"><code>Input.just_released</code></a> for the release edge and <a href="input-active.html"><code>Input.active</code></a> for the held state.

```ludic
program Press {
  entry {
    Input.action("jump", ' ')
    if Input.just_pressed("jump") { print(1) }
  }
}
```
