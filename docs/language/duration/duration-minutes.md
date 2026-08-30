---
id: duration-minutes
name: Duration.minutes
category: duration
kind: namespace-method
tokens: Duration.minutes
sig: Duration.minutes(n) -> int
tip: A span of n minutes, in seconds.
order: 1
ns: Duration
member: minutes
---

A span of <code>n</code> minutes, returned in seconds (<code>n * 60</code>).

```ludic
program Demo {
  handler Step phase Update {
    let respawn = Duration.minutes(2)
  }
}
```
