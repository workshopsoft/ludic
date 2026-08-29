---
id: fn-max
name: max
category: builtins
kind: builtin
tokens: max
sig: max(a, b) -> int
tip: The larger of two integers.
order: 50
---

Returns whichever of its two integer arguments is larger. Use it to enforce a lower bound (for example clamping a countdown so it never drops below zero with <code>max(remaining, 0)</code>), to track a running high score, or to pick the greater of two candidate values. For the smaller of two values use <code>min</code>, and to bound a value on both sides at once use <code>clamp</code>.

Parameters:
- `a` — the first value
- `b` — the second value

```ludic
program HighScore {
  var score: int = 0
  var best_score: int = 0

  handler EarnPoints phase Update {
    score = score + 5
    best_score = max(best_score, score)
    if score >= 20 { quit() }
  }

  handler ReportBest phase Render {
    Screen.clear(Color.MidnightBlue)
    Screen.draw_number(x: 8, y: 8, value: best_score, color: Color.Gold, scale: 1)
    Screen.show()
  }
}
```
