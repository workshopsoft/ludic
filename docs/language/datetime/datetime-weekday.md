---
id: datetime-weekday
name: DateTime.weekday
category: datetime
kind: namespace-method
tokens: DateTime.weekday
sig: DateTime.weekday(dt) -> int
tip: Day of the week, 0=Sunday..6=Saturday.
order: 6
ns: DateTime
member: weekday
---

The day of the week of the instant <code>dt</code> (UTC), <code>0</code> (Sunday) through <code>6</code> (Saturday).

```ludic
program Demo {
  handler Step phase Update {
    let w = DateTime.weekday(DateTime.from(2000, 1, 1, 12, 0, 0))   # 6
  }
}
```
