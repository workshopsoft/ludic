---
id: date-weekday
name: Date.weekday
category: date
kind: namespace-method
tokens: Date.weekday
sig: Date.weekday(date) -> int
tip: Day of the week, 0=Sunday..6=Saturday.
order: 4
ns: Date
member: weekday
---

The day of the week of a <code>Date</code>, as <code>0</code> (Sunday) through <code>6</code> (Saturday). Useful for weekly events or daily-reward streaks.

```ludic
program Demo {
  handler Step phase Update {
    let w = Date.weekday(Date.new(2000, 1, 1))  # 6 (Saturday)
  }
}
```
