---
id: date-days_in_month
name: Date.days_in_month
category: date
kind: namespace-method
tokens: Date.days_in_month
sig: Date.days_in_month(year, month) -> int
tip: Number of days in a given month.
order: 6
ns: Date
member: days_in_month
---

The number of days in <code>month</code> of <code>year</code> (28&ndash;31), accounting for leap Februaries.

```ludic
program Demo {
  handler Step phase Update {
    let n = Date.days_in_month(2024, 2)   # 29
  }
}
```
