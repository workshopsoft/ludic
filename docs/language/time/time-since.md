---
id: time-since
name: Time.since
category: time
kind: namespace-method
tokens: Time.since
sig: Time.since(past) -> int
tip: Seconds elapsed from a past instant to now (non-deterministic).
order: 4
ns: Time
member: since
---

The number of seconds elapsed from the <code>DateTime</code> <code>past</code> to now (<code>Time.now() - past</code>). Because it reads the wall clock it is <b>non-deterministic</b> &mdash; use it for offline-progress and "time away" checks, never inside the lockstep simulation. The result is a <code>Duration</code> in seconds, ready for the <code>Duration.as_*</code> readers.

```ludic
program Demo {
  handler Step phase Update {
    let last_seen = DateTime.from(2026, 8, 30, 9, 0, 0)
    let away = Time.since(last_seen)
    let hours_away = Duration.as_hours(away)
  }
}
```
