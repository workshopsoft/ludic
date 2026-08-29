---
id: math-move_toward
name: Math.move_toward
category: math
kind: namespace-method
tokens: Math.move_toward
sig: Math.move_toward(from, to, delta) -> fixed
tip: Step from one value toward another by at most delta.
order: 24
ns: Math
member: move_toward
---

Moves <code>from</code> toward <code>to</code> by at most <code>delta</code>, never overshooting — when the gap is smaller than <code>delta</code> it returns exactly <code>to</code>. Unlike <code>Math.lerp</code>, which eases by a fraction of the remaining distance, this moves at a constant rate, which is what you want for turrets, meters, and UI values that should approach a target steadily and then stop.

```ludic
program Demo {
  handler Step phase Update {
    health_shown = Math.move_toward(health_shown, health, 2.0)
  }
}
```
