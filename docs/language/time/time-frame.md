---
id: time-frame
name: Time.frame
category: time
kind: namespace-method
tokens: Time.frame
sig: Time.frame() -> int
tip: The number of frames elapsed since start.
order: 0
ns: Time
member: frame
---

Returns how many frames have completed since the program started, incrementing once per frame. Deterministic — the same replay reaches the same frame count. Use it to time events (<code>if Time.frame() % 30 == 0</code>), drive animations, or seed per-frame variation.

```ludic
program Demo {
  handler Step phase Update {
    if Time.frame() % 60 == 0 { tick() }
  }
}
```
