---
id: op-assign
name: Assignment
category: operators
kind: operator
sig: name = value
tip: Store into a var, a field, or an element — a statement, not an expression.
order: 5
---

Assignment stores a value into a target — a `var` binding, a property field, or a buffer/slice element — with `target = value`. The compound forms `+=`, `-=`, `*=`, and `/=` update in place, so `score += 1` means `score = score + 1`. Assignment is a <b>statement, not an expression</b>: it produces no value, so you cannot write `if x = 0` (use `==` for the test). Only a mutable target accepts it — assigning to a `let` or `const` binding is a compile error — though you may still mutate <b>through</b> an immutable binding that holds a record or slice.

```ludic
var score: int = 0
score = 10
score += 5
let current_position = new_position()
current_position.column = current_position.column + 1
```
