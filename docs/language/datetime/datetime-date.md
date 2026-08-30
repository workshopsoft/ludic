---
id: datetime-date
name: DateTime.date
category: datetime
kind: namespace-method
tokens: DateTime.date
sig: DateTime.date(dt) -> int
tip: The calendar day the instant falls on.
order: 1
ns: DateTime
member: date
---

The <code>Date</code> (days since 1970) that the instant <code>dt</code> falls on, dropping the time of day.

```ludic
program Demo {
  handler Step phase Update {
    let today = DateTime.date(Time.now())
  }
}
```
