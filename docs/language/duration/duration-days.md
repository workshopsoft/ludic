---
id: duration-days
name: Duration.days
category: duration
kind: namespace-method
tokens: Duration.days
sig: Duration.days(n) -> int
tip: A span of n days, in seconds.
order: 3
ns: Duration
member: days
---

A span of <code>n</code> days, returned in seconds (<code>n * 86400</code>).

```ludic
program Demo {
  handler Step phase Update {
    let week = Duration.days(7)
  }
}
```
