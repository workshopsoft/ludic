---
id: datetime-second
name: DateTime.second
category: datetime
kind: namespace-method
tokens: DateTime.second
sig: DateTime.second(dt) -> int
tip: The second of the minute (0-59) of an instant.
order: 9
ns: DateTime
member: second
---

The second within the minute of the instant <code>dt</code> (UTC), <code>0</code>&ndash;<code>59</code>.

```ludic
program Demo {
  handler Step phase Update {
    let s = DateTime.second(DateTime.from(2000, 1, 1, 12, 30, 15))   # 15
  }
}
```
