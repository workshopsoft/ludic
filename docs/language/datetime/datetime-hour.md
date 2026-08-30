---
id: datetime-hour
name: DateTime.hour
category: datetime
kind: namespace-method
tokens: DateTime.hour
sig: DateTime.hour(dt) -> int
tip: The hour of day (0-23) of an instant.
order: 7
ns: DateTime
member: hour
---

The hour of the day of the instant <code>dt</code> (UTC), <code>0</code>&ndash;<code>23</code>. Drives day/night cycles from a real clock.

```ludic
program Demo {
  handler Step phase Update {
    let h = DateTime.hour(DateTime.from(2000, 1, 1, 12, 30, 15))   # 12
  }
}
```
