---
id: annot-onenable
name: @OnEnable
category: annotations
kind: annotation
tokens: @OnEnable
sig: @OnEnable(Property) handler Name { … }
tip: Run a handler when a paused property is re-enabled on an instance.
order: 50
---

<code>@OnEnable(Property)</code> fires when a property that is present but disabled is turned back on with <code>enable P on e</code>. Unlike <code>@OnAttach</code>, the property's data was never destroyed — enable/disable only pause and resume a property that already exists, keeping its fields intact — so this hook is about a capability becoming active again rather than being created. The body runs in the instance's context and can read the retained field values. Use the enable/disable pair for a capability that toggles repeatedly (a power-up, a stun) where re-seeding on every toggle would be wrong. Add <code>@Public</code> to also emit a <code>prop_&lt;Property&gt;_enable</code> event.

```ludic
program EnableHook {
  property Tag    { value: int = 0 }
  property Shield { amount: int = 0 }
  model Unit { Tag, Shield }

  @OnEnable(Shield) handler ShieldBackOnline {       # fires when Shield is re-enabled
    print(Shield.amount)                             # 5 — the retained amount, not re-seeded
  }

  handler Seed phase Start {
    spawn Unit { Tag { value: 1 }, Shield { amount: 5 } }
    for (unit) in query [Unit] { disable Shield on self() }
  }

  handler Reactivate phase Render {
    for (unit) in query [Unit] { enable Shield on self() }         # triggers @OnEnable
    quit()
  }
}
```
