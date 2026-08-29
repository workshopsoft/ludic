---
id: type-bool
name: bool
category: types
kind: type
tokens: bool
sig: bool
tip: A truth value — the result of comparisons and of and / or / not.
order: 2
---

`bool` is a truth value, either `true` or `false`. It is what a comparison (`== != < <= > >=`) yields and what the boolean combinators `and`, `or`, and `not` produce and consume. A `bool` is what an `if` or `while` condition tests, and some builtins return one directly — `Random.chance(percent:)` answers `true` or `false`. Ludic spells the combinators as words, not symbols: write `and` / `or` / `not`, never `&&`, `||`, or a bare `!`.

```ludic
let is_alive: bool = current_health > 0
let should_spawn: bool = Random.chance(percent: 25)
if is_alive and should_spawn { spawn Enemy { } }
```
