---
id: datetime-add
name: DateTime.add
category: datetime
kind: namespace-method
tokens: DateTime.add
sig: DateTime.add(dt, span) -> int
tip: The instant `span` seconds later.
order: 2
ns: DateTime
member: add
---

The instant <code>span</code> seconds after <code>dt</code>. Pair it with the <code>Duration</code> constructors to express the offset in real units.

```ludic
program Demo {
  handler Step phase Update {
    let ready_at = DateTime.add(Time.now(), Duration.hours(3))
  }
}
```
