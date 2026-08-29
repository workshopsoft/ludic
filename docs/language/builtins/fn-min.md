---
id: fn-min
name: min
category: builtins
kind: builtin
tokens: min
sig: min(a, b) -> int
tip: The smaller of two integers.
order: 50
---

Returns whichever of its two integer arguments is smaller. Use it to enforce an upper bound — for instance capping healing so it never exceeds a maximum with <code>min(current + heal, maximum)</code> — or to pick the lesser of two candidate values. For the larger of two values use <code>max</code>, and to bound a value between a low and a high at once use <code>clamp</code>.

Parameters:
- `a` — the first value
- `b` — the second value

```ludic
program CappedHealing {
  property Health { current: int = 100, maximum: int = 100 }
  model Player { Health }

  handler SpawnPlayer phase Start {
    spawn Player { Health { current: 90, maximum: 100 } }
  }

  handler ApplyHeal phase Update {
    for (Health) in query [Health, {Player}] {
      Health.current = min(Health.current + 25, Health.maximum)
    }
  }

  handler ReportHealth phase Render {
    Screen.clear(Color.MidnightBlue)
    for (Health) in query [Health, {Player}] {
      Screen.draw_number(x: 8, y: 8, value: Health.current, color: Color.LimeGreen, scale: 1)
    }
    Screen.show()
  }
}
```
