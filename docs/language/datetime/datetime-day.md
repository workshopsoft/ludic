---
id: datetime-day
name: DateTime.day
category: datetime
kind: namespace-method
tokens: DateTime.day
sig: DateTime.day(dt) -> int
tip: The day of the month (1-31) of an instant.
order: 5
ns: DateTime
member: day
---

The day of the month of the instant <code>dt</code> (UTC), <code>1</code>&ndash;<code>31</code>.

```ludic
program Demo {
  handler Step phase Update {
    let d = DateTime.day(DateTime.from(2000, 3, 9, 0, 0, 0))   # 9
  }
}
```
