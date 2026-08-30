---
id: date-add_days
name: Date.add_days
category: date
kind: namespace-method
tokens: Date.add_days
sig: Date.add_days(date, n) -> int
tip: The date n days later (n may be negative).
order: 8
ns: Date
member: add_days
---

The <code>Date</code> that is <code>n</code> days after <code>date</code>; pass a negative <code>n</code> to go backward. Rolls across month and year boundaries automatically.

```ludic
program Demo {
  handler Step phase Update {
    let tomorrow = Date.add_days(Date.new(2026, 12, 31), 1)   # 2027-01-01
  }
}
```
