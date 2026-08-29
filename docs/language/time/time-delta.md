---
id: time-delta
name: Time.delta
category: time
kind: namespace-method
tokens: Time.delta
sig: Time.delta() -> fixed
tip: Seconds per frame (a fixed 1/60).
order: 1
ns: Time
member: delta
---

Returns the duration of one frame in seconds as a <code>fixed</code> — a constant <code>1/60</code>, since the frame clock is fixed-step. Multiply a per-second rate by it to advance movement or timers by one frame's worth.

```ludic
program Demo {
  handler Step phase Update {
    x = x + speed_per_second * Time.delta()
  }
}
```
