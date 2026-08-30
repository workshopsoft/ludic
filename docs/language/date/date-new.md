---
id: date-new
name: Date.new
category: date
kind: namespace-method
tokens: Date.new
sig: Date.new(year, month, day) -> int
tip: A calendar day as days-since-1970.
order: 0
ns: Date
member: new
---

Builds a <code>Date</code> from a calendar <code>year</code>, <code>month</code> (1&ndash;12) and <code>day</code> (1&ndash;31), returning the count of days since 1970-01-01 (UTC). Read the parts back with <code>Date.year</code>/<code>Date.month</code>/<code>Date.day</code>.

```ludic
program Demo {
  handler Step phase Update {
    let launch = Date.new(2026, 8, 30)
  }
}
```
