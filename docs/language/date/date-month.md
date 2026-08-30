---
id: date-month
name: Date.month
category: date
kind: namespace-method
tokens: Date.month
sig: Date.month(date) -> int
tip: The month (1-12) of a date.
order: 2
ns: Date
member: month
---

The calendar month of a <code>Date</code>, from <code>1</code> (January) to <code>12</code> (December).

```ludic
program Demo {
  handler Step phase Update {
    let m = Date.month(Date.new(2026, 8, 30))  # 8
  }
}
```
