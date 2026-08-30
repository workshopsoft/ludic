---
id: clock-reset
name: Clock.reset
category: clock
kind: namespace-method
tokens: Clock.reset
sig: Clock.reset()
tip: Reset the clock to the epoch (0).
order: 3
ns: Clock
member: reset
---

Resets the simulated clock back to <code>0</code> (the 1970 epoch). Handy at the start of a new run or a replay.

```ludic
program Demo {
  handler Step phase Update {
    Clock.reset()
  }
}
```
