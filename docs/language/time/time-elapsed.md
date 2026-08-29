---
id: time-elapsed
name: Time.elapsed
category: time
kind: namespace-method
tokens: Time.elapsed
sig: Time.elapsed() -> fixed
tip: Seconds since start (deterministic).
order: 2
ns: Time
member: elapsed
---

Returns the time since the program started, in seconds, as a <code>fixed</code> — exactly <code>Time.frame()</code> divided by 60. Deterministic and replay-safe. Use it for wave timers, day/night cycles, and anything paced in seconds.

```ludic
program Demo {
  handler Step phase Update {
    if Time.elapsed() > 10.0 { start_wave() }
  }
}
```
