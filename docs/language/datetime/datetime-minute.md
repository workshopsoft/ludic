---
id: datetime-minute
name: DateTime.minute
category: datetime
kind: namespace-method
tokens: DateTime.minute
sig: DateTime.minute(dt) -> int
tip: The minute of the hour (0-59) of an instant.
order: 8
ns: DateTime
member: minute
---

The minute within the hour of the instant <code>dt</code> (UTC), <code>0</code>&ndash;<code>59</code>.

```ludic
program Demo {
  handler Step phase Update {
    let mi = DateTime.minute(DateTime.from(2000, 1, 1, 12, 30, 15))   # 30
  }
}
```
