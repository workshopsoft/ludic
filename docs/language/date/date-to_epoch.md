---
id: date-to_epoch
name: Date.to_epoch
category: date
kind: namespace-method
tokens: Date.to_epoch
sig: Date.to_epoch(date) -> int
tip: Midnight UTC of the day, as a DateTime.
order: 7
ns: Date
member: to_epoch
---

The instant at midnight (00:00:00 UTC) of the given <code>Date</code>, as a <code>DateTime</code> (seconds since 1970). Bridges a calendar day back to the wall-clock timeline.

```ludic
program Demo {
  handler Step phase Update {
    let t = Date.to_epoch(Date.new(2026, 8, 30))
  }
}
```
