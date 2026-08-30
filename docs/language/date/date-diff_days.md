---
id: date-diff_days
name: Date.diff_days
category: date
kind: namespace-method
tokens: Date.diff_days
sig: Date.diff_days(a, b) -> int
tip: Whole days from b to a (a - b).
order: 9
ns: Date
member: diff_days
---

The number of whole days from <code>b</code> to <code>a</code> (that is, <code>a - b</code>). Negative when <code>a</code> precedes <code>b</code>.

```ludic
program Demo {
  handler Step phase Update {
    let gap = Date.diff_days(Date.new(2026, 1, 1), Date.new(2025, 1, 1))   # 365
  }
}
```
