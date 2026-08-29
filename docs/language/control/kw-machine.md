---
id: kw-machine
name: machine
category: control
kind: keyword
tokens: machine
sig: machine store { state Name { … } }
tip: An explicit state machine over an int var — dispatches on the store's value.
order: 6
---

A <code>machine</code> turns an integer store into an explicit state machine, replacing brittle `if phase == N` chains. It reads the store — a named program-scope `var` is the modern choice — and dispatches to the matching `state` block; inside a state, `become Name` transitions to another state of the same machine. States number themselves by declaration order (the first is `0`, the next `1`, and so on), so you never write magic constants, though `state Name = expr` is accepted when a state needs a specific value. Because `become` compiles to a single store back into the `var`, the whole machine lowers to plain branches with no dispatch table. Place a `machine` inside a handler so it runs each frame.

```ludic
program TurnOrder {
  enum Phase { KnightMenu, KnightResolve, EnemyTurn }
  var battle_phase: int = Phase.KnightMenu

  handler RunTurn phase Update {
    machine battle_phase {
      state KnightMenu {
        if Input.key() == ' ' { become KnightResolve }
      }
      state KnightResolve {
        become EnemyTurn
      }
      state EnemyTurn {
        become KnightMenu
      }
    }
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    Screen.draw_number(x: 8, y: 8, value: battle_phase, color: Color.Gold, scale: 2)
    Screen.show()
  }
}
```
