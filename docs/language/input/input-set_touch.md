---
id: input-set_touch
name: Input.set_touch
category: input
kind: namespace-method
tokens: Input.set_touch
sig: Input.set_touch(index, x, y, active)
tip: Inject a touch point.
order: 30
ns: Input
member: set_touch
---

Injects touch point <code>index</code> (0..7): <code>active</code> with a position, or inactive. A platform touch binding feeds the same points; until then this drives multi-touch from replays, AI, or the network.

```ludic
program Demo {
  entry {
    Input.set_touch(0, 64, 64, true)
    print(Input.touch_count())
  }
}
```
