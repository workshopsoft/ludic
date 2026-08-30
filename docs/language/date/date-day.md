---
id: date-day
name: Date.day
category: date
kind: namespace-method
tokens: Date.day
sig: Date.day(date) -> int
tip: The day of the month (1-31) of a date.
order: 3
ns: Date
member: day
---

The day of the month of a <code>Date</code>, from <code>1</code> to <code>31</code>.

```ludic
program Demo {
  handler Step phase Update {
    let d = Date.day(Date.new(2026, 8, 30))    # 30
  }
}
```
