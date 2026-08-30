---
id: date-is_leap
name: Date.is_leap
category: date
kind: namespace-method
tokens: Date.is_leap
sig: Date.is_leap(year) -> bool
tip: True if the year is a leap year.
order: 5
ns: Date
member: is_leap
---

Whether <code>year</code> is a leap year on the proleptic Gregorian calendar: divisible by 4, except centuries, which must be divisible by 400.

```ludic
program Demo {
  handler Step phase Update {
    let leap = Date.is_leap(2024)   # true
  }
}
```
