---
id: input-key_released
name: Input.key_released
category: input
kind: namespace-method
tokens: Input.key_released
sig: Input.key_released(key) -> bool
tip: Did a key go up this frame (edge)?
order: 10
ns: Input
member: key_released
---

Returns whether a key went up this frame — held last frame, not held now. The falling edge, for release-triggered actions (charge-and-release, letting go of a grip).

```ludic
program Demo {
  entry {
    Input.press('a')
    Input.poll()
    Input.release('a')
    Input.poll()
    if Input.key_released('a') { print(1) }
  }
}
```
