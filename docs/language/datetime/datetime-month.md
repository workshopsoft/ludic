---
id: datetime-month
name: DateTime.month
category: datetime
kind: namespace-method
tokens: DateTime.month
sig: DateTime.month(dt) -> int
tip: The month (1-12) of an instant.
order: 4
ns: DateTime
member: month
---

The calendar month of the instant <code>dt</code> (UTC), <code>1</code>&ndash;<code>12</code>.

```ludic
program Demo {
  handler Step phase Update {
    let m = DateTime.month(DateTime.from(2000, 3, 9, 0, 0, 0))   # 3
  }
}
```
