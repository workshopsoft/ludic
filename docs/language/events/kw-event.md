---
id: kw-event
name: event
category: events
kind: keyword
tokens: event
sig: event Name { field: T = default }
tip: Declare a public event carrying a flat payload that listeners react to.
order: 0
---

`event` declares a public event — a named signal carrying a flat payload of typed fields (each with a default; the payload may be empty). Where lifecycle hooks are the closed reactions the author compiles in, events are the <b>open runtime surface a game exposes to mods</b>: an in-language listener registers with `@On(Name)` and reads the payload fields by name, and `emit Name(field: value, …)` fires every listener in declaration order as a direct call. It all desugars to a generated function — there is no interpreter and no dispatch table — and a program that declares no `event` compiles byte-for-byte as before. Mark an event `cancellable` when a listener should be able to veto the action it announces.

```ludic
program EventExample {
  event EnemyDefeated { points: int = 0 }

  var score: int = 0

  @On(EnemyDefeated) handler AddScore { score = score + points }
  @On(EnemyDefeated) handler PlayChime { Screen.status("enemy down") }

  handler ScoreOnKey phase Update {
    if Input.key() == 'k' { emit EnemyDefeated(points: 10) }
  }

  handler DrawWorld phase Render {
    Screen.clear(Color.MidnightBlue)
    Screen.draw_number(x: 4, y: 4, value: score, color: Color.Gold, scale: 1)
    Screen.show()
  }
}
```
