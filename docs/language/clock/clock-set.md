---
id: clock-set
name: Clock.set
category: clock
kind: namespace-method
tokens: Clock.set
sig: Clock.set(t)
tip: Set the clock to an instant.
order: 1
ns: Clock
member: set
---

Sets the simulated clock to the instant <code>t</code>. Typically called once on load (e.g. from a saved <code>Time.now()</code>), after which gameplay advances it deterministically.

```ludic
program Demo {
  handler Step phase Update {
    Clock.set(DateTime.from(2026, 8, 30, 8, 0, 0))
  }
}
```
