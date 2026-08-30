---
id: duration-as_minutes
name: Duration.as_minutes
category: duration
kind: namespace-method
tokens: Duration.as_minutes
sig: Duration.as_minutes(span) -> int
tip: The span in whole minutes.
order: 5
ns: Duration
member: as_minutes
---

The span expressed in whole minutes, truncated toward zero (<code>span / 60</code>).

```ludic
program Demo {
  handler Step phase Update {
    let m = Duration.as_minutes(Duration.hours(2))     # 120
  }
}
```
