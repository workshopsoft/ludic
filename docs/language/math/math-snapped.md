---
id: math-snapped
name: Math.snapped
category: math
kind: namespace-method
tokens: Math.snapped
sig: Math.snapped(v, step) -> fixed
tip: Round a value to the nearest multiple of step.
order: 23
ns: Math
member: snapped
---

Rounds <code>v</code> to the nearest multiple of <code>step</code> (both <code>fixed</code>) — for snapping a position to a grid, quantizing an angle to 8 directions, or rounding a value to a tidy increment. <code>Math.snapped(x, 16.0)</code> snaps <code>x</code> to a 16-unit grid.

```ludic
program Demo {
  handler Step phase Update {
    let gx = Math.snapped(world_x, 16.0)
  }
}
```
