---
id: type-void
name: void
category: types
kind: type
tokens: void
sig: void
tip: The absence of a value — the return type of a function that returns nothing.
order: 50
---

`void` is the absence of a value. It appears as the return type of a function that runs for its effect and hands nothing back — `fn reset_score() -> void { … }`. Such a function is called as a statement, not used in an expression, and a bare `return` (with no value) leaves it early. Use `void` whenever a helper mutates program state, draws, or spawns rather than computing a result to return.

```ludic
fn reset_score() -> void {
  score = 0
  return
}
```
