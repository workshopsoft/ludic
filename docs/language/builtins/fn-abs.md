---
id: fn-abs
name: abs
category: builtins
kind: builtin
tokens: abs
sig: abs(a) -> int
tip: The absolute value of an integer (its magnitude, never negative).
order: 8
---

Returns the magnitude of an integer, dropping its sign — so <code>abs(-7)</code> and <code>abs(7)</code> both give <code>7</code>. It is handy for distance-style checks where direction does not matter, such as measuring how far two grid cells are apart along one axis before deciding whether something is "close enough". Combine two axis distances to build a simple proximity test. It takes a single integer and returns an integer.

Parameters:
- `a` — the integer whose magnitude you want

```ludic
program Proximity {
  property Position { column: int = 0, row: int = 0 }
  model Player { Position }
  model Enemy { Position }

  handler SpawnActors phase Start {
    spawn Player { Position { column: 5, row: 5 } }
    spawn Enemy { Position { column: 8, row: 6 } }
  }

  handler CheckAdjacency phase Update {
    for (PlayerPosition) in query [Position, {Player}] {
      for (EnemyPosition) in query [Position, {Enemy}] {
        let column_gap = abs(PlayerPosition.column - EnemyPosition.column)
        let row_gap = abs(PlayerPosition.row - EnemyPosition.row)
        if column_gap + row_gap <= 1 { print(1) }
      }
    }
  }
}
```
