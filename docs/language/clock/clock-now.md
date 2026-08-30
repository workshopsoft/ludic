---
id: clock-now
name: Clock.now
category: clock
kind: namespace-method
tokens: Clock.now
sig: Clock.now() -> int
tip: The current simulated instant.
order: 0
ns: Clock
member: now
---

The current value of the simulated clock, as a <code>DateTime</code> (seconds since 1970). Deterministic &mdash; it returns exactly what the game last set or advanced it to, never the wall clock.

```ludic
program Demo {
  handler Step phase Update {
    let t = Clock.now()
    let hour = DateTime.hour(t)
  }
}
```
