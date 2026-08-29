---
id: time-now
name: Time.now
category: time
kind: namespace-method
tokens: Time.now
sig: Time.now() -> int
tip: Wall-clock seconds (non-deterministic).
order: 3
ns: Time
member: now
---

Returns the real-world time in seconds since the Unix epoch. This is the wall clock and is <b>non-deterministic</b> — never feed it into the lockstep simulation or a replay. Use it only for seeding <code>Random.seed</code> or for telemetry.

```ludic
program Demo {
  handler Step phase Update {
    Random.seed(value: Time.now())
  }
}
```
