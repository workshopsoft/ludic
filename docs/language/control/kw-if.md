---
id: kw-if
name: if / else
category: control
kind: keyword
tokens: if else
sig: if cond { … } else { … }
tip: A branch — run one block when a condition holds, another when it doesn't.
order: 0
---

An <code>if</code> runs its block when the condition is true; an optional `else` block runs when it is false, and the `else` may itself be another `if` to form a ladder. The condition is a plain boolean expression with <b>no surrounding parentheses</b>, and the braces are always required even for a single statement. Ludic's boolean operators are the words `and`, `or` and `not` (not `&&`/`||`/`!`), and note that bitwise operators bind tighter than comparison, so `flags & MASK == 0` already means `(flags & MASK) == 0`. When the branches grow into a chain testing one value against several constants, reach for `match` instead.

```ludic
program Threshold {
  property Health { current: int = 100, maximum: int = 100 }
  model Player { Health }

  handler Boot phase Start {
    spawn Hero { Health { current: 25 } }
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    for (health) in query [Health, {Player}] {
      if health.current <= 0 {
        Screen.draw_text(x: 8, y: 8, text: "DEFEATED", color: Color.Crimson, scale: 2)
      } else {
        if health.current < 30 {
          Screen.draw_text(x: 8, y: 8, text: "DANGER", color: Color.Gold, scale: 2)
        } else {
          Screen.draw_text(x: 8, y: 8, text: "OK", color: Color.LimeGreen, scale: 2)
        }
      }
    }
    Screen.show()
  }
}
```
