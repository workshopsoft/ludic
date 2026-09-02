---
id: input-just_released
name: Input.just_released
category: input
kind: namespace-method
tokens: Input.just_released
sig: Input.just_released(action: str) -> bool
tip: Did a named action go inactive this frame (the on-release edge)?
order: 35
ns: Input
member: just_released
---

Returns whether a named action went inactive this frame — not active now, active last frame. The on-release edge over the device layer (keyboard or pad), symmetric with <a href="input-just_pressed.html"><code>Input.just_pressed</code></a>. Use it for release-triggered actions (variable-height jump cut-off, charge-and-release). Deterministic, so a replay fires the same edges.

```ludic
program Release {
  entry {
    Input.action("charge", ' ')
    if Input.just_released("charge") { print(1) }
  }
}
```
