---
id: date-year
name: Date.year
category: date
kind: namespace-method
tokens: Date.year
sig: Date.year(date) -> int
tip: The calendar year of a date.
order: 1
ns: Date
member: year
---

The calendar year of a <code>Date</code>.

```ludic
program Demo {
  handler Step phase Update {
    let y = Date.year(Date.new(2026, 8, 30))   # 2026
  }
}
```
