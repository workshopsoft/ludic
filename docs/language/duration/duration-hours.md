---
id: duration-hours
name: Duration.hours
category: duration
kind: namespace-method
tokens: Duration.hours
sig: Duration.hours(n) -> int
tip: A span of n hours, in seconds.
order: 2
ns: Duration
member: hours
---

A span of <code>n</code> hours, returned in seconds (<code>n * 3600</code>). Handy as a threshold for offline-progress checks.

```ludic
program Demo {
  handler Step phase Update {
    let full_day = Duration.hours(24)
  }
}
```
