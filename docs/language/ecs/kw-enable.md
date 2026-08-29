---
id: kw-enable
name: enable
category: ecs
kind: keyword
tokens: enable
sig: enable Prop on entity
tip: Re-activate a disabled property, model, or handler — its data is intact.
order: 4
---

<code>enable</code> reverses a <code>disable</code>: it turns something back on without recreating it. `enable Prop on instance` restores a property's has-flag so queries match the instance again, with the field values exactly as they were left — nothing was copied or freed, so re-enabling is cheap and lossless. There are three scopes, matching `disable`: a single property on one instance (`enable Shield on self()`), a whole model (`enable Enemy`, all its instances rejoin every query), and a handler (`enable AiThink`, it resumes running each phase). Re-enabling a property fires any `@OnEnable(Prop)` hook at the toggle point. Reach for enable/disable when you want to pause and resume, and for `attach`/`detach` when you want to add or structurally remove.

```ludic
program ShieldToggle {
  property Position { column: int = 0, row: int = 0 }
  property Shield   { amount: int = 0 }
  model Player { Position, Shield }

  handler Boot phase Start {
    spawn Hero { Position { column: 8, row: 8 }; Shield { amount: 3 } }
    disable Shield on self()
  }

  handler RestoreShield phase Update {
    if Input.key() == ' ' {
      for (position) in query [Position, {Player}] { enable Shield on self() }
    }
  }
}
```
