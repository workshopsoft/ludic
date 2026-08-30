---
id: duration-as_days
name: Duration.as_days
category: duration
kind: namespace-method
tokens: Duration.as_days
sig: Duration.as_days(span) -> int
tip: The span in whole days.
order: 7
ns: Duration
member: as_days
---

The span expressed in whole days, truncated toward zero (<code>span / 86400</code>).

```ludic
program Demo {
  handler Step phase Update {
    let d = Duration.as_days(Duration.hours(50))       # 2
  }
}
```
