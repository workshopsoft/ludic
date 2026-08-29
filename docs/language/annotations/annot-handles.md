---
id: annot-handles
name: @Handles
category: annotations
kind: annotation
tokens: @Handles
sig: @Handles(Event) handler Name { … }
tip: Declarative hint naming the event or subsystem a handler is responsible for.
order: 50
---

<code>@Handles</code> is a declarative annotation that names the event or subsystem a handler (or a whole program) is responsible for. The parser accepts and records it as metadata for analysis and tooling — it does not by itself wire up dispatch, so it documents intent rather than driving execution. When you want a handler to actually run in response to an event, use <code>@On(Event)</code>, which registers the listener; <code>@Handles</code> is the companion label that makes ownership of an event legible across a modular codebase. Keep the named symbol a real event or system so the annotation stays meaningful.

```ludic
program CombatModule {
  property Health { current: int = 100 }
  model Enemy { Health }

  event DamageDealt { amount: int = 0 }

  @Handles(DamageDealt)                              # documents this handler's responsibility
  @On(DamageDealt) handler ApplyDamage {             # @On does the actual dispatch wiring
    for (Health) in query [Health, {Enemy}] {
      Health.current = Health.current - amount
    }
  }

  entry {
    spawn Enemy { Health { current: 100 } }
    emit DamageDealt(amount: 25)
  }
}
```
