---
id: op-compare
name: Comparison
category: operators
kind: operator
sig: ==  !=  <  <=  >  >=
tip: Compare two values and yield a bool; on strings == compares contents.
order: 1
---

The comparison operators — `==` (equal), `!=` (not equal), `<`, `<=`, `>`, `>=` — take two values and yield a `bool`, the kind of test an `if` or `where` clause wants. On `string` values `==` and `!=` compare <b>by content</b>, so `direction == "left"` checks the characters, not the pointer (a comparison against `null` stays a pointer test). Comparison binds looser than arithmetic and looser than the bitwise operators, so `flags & MASK == 0` reads as `(flags & MASK) == 0` with no parentheses needed. Chain several conditions together with `and` / `or`.

```ludic
if current_health <= 0 { become GameOver }
if pressed_key == 'w' and elapsed_frames > 0 { row = row - 1 }
```
