---
id: duration-as_hours
name: Duration.as_hours
category: duration
kind: namespace-method
tokens: Duration.as_hours
sig: Duration.as_hours(span) -> int
tip: The span in whole hours.
order: 6
ns: Duration
member: as_hours
---

The span expressed in whole hours, truncated toward zero (<code>span / 3600</code>). Useful for turning an elapsed-time gap into a reward count.

```ludic
program Demo {
  handler Step phase Update {
    let h = Duration.as_hours(Duration.days(3))        # 72
  }
}
```
