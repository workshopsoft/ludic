---
id: datetime-from
name: DateTime.from
category: datetime
kind: namespace-method
tokens: DateTime.from
sig: DateTime.from(year, month, day, hour, minute, second) -> int
tip: Build an instant from its calendar parts.
order: 0
ns: DateTime
member: from
---

Builds a <code>DateTime</code> (seconds since 1970, UTC) from calendar and clock parts. The inverse of the component readers below.

```ludic
program Demo {
  handler Step phase Update {
    let t = DateTime.from(2000, 1, 1, 12, 30, 15)
  }
}
```
