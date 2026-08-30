---
id: datetime-year
name: DateTime.year
category: datetime
kind: namespace-method
tokens: DateTime.year
sig: DateTime.year(dt) -> int
tip: The calendar year of an instant.
order: 3
ns: DateTime
member: year
---

The calendar year of the instant <code>dt</code> (UTC).

```ludic
program Demo {
  handler Step phase Update {
    let y = DateTime.year(DateTime.from(2000, 1, 1, 12, 30, 15))   # 2000
  }
}
```
