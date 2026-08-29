---
id: kw-detach
name: detach
category: ecs
kind: keyword
tokens: detach
sig: detach Prop on entity
tip: Structurally remove a property from a live model instance.
order: 7
---

<code>detach</code> removes a property from a live model instance, firing the property's `@OnDetach(Prop)` hook <b>before</b> the has-flag clears — so the hook can still read the outgoing field values as it tears down. It is the structural opposite of `attach`: where `disable` pauses a property but keeps its data for a later `enable`, `detach` genuinely removes the property, and a later `attach` re-seeds fresh fields from defaults. Detaching a property the instance does not have is a no-op. Reach for it when something is gone for good — a shield consumed, a status effect that has run its course, an ability removed.

```ludic
program ShieldBreak {
  property Position { column: int = 0, row: int = 0 }
  property Shield   { amount: int = 0 }
  model Player { Position, Shield }

  handler Boot phase Start {
    spawn Hero { Position { column: 6, row: 6 }; Shield { amount: 1 } }
  }

  handler ConsumeShield phase Update {
    for (shield) in query [Shield, {Player}] {
      if shield.amount <= 0 { detach Shield on self() }
    }
  }
}
```
