---
id: op-logical
name: Logical
category: operators
kind: operator
sig: and  or  not
tip: The boolean combinators, spelled as words — never && or || or a bare !.
order: 2
---

The boolean combinators are `and`, `or`, and `not`. They combine `bool` values — usually the results of comparisons — into the compound conditions an `if`, `while`, or `where` clause tests. Ludic spells them as <b>words, not symbols</b>: `&&` and `||` are not operators, and a bare `!` is rejected with a diagnostic pointing you to `not` (`!=` is unaffected). `and` binds tighter than `or`, so `a and b or c` groups as `(a and b) or c`; add parentheses when you mean otherwise.

```ludic
if pressed_key != 0 and not is_paused { apply_input() }
if current_health <= 0 or elapsed_frames > time_limit { become GameOver }
```
