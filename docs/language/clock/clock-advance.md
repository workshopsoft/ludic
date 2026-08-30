---
id: clock-advance
name: Clock.advance
category: clock
kind: namespace-method
tokens: Clock.advance
sig: Clock.advance(span)
tip: Move the clock forward by a Duration.
order: 2
ns: Clock
member: advance
---

Moves the simulated clock forward by <code>span</code> seconds &mdash; pair it with the <code>Duration.*</code> constructors. Advance it by a fixed step each tick to drive a deterministic day/night or season cycle.

```ludic
program Demo {
  handler Step phase Update {
    Clock.advance(Duration.minutes(1))   # one in-game minute per call
  }
}
```
