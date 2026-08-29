---
id: annot-onattach
name: @OnAttach
category: annotations
kind: annotation
tokens: @OnAttach
sig: @OnAttach(Property) handler Name { … }
tip: Run a handler when a property is structurally attached to a live instance.
order: 50
---

<code>@OnAttach(Property)</code> fires when the named property is <b>structurally added</b> to a live model instance with <code>attach P on e</code> — the property's fields are seeded first, then the hook runs in the context of that instance so it can read and adjust them. This is the structural birth of a property, the counterpart to <code>@OnDetach</code>; it differs from <code>@OnEnable</code>, which only un-pauses a property that already exists. Use it to react when a capability appears on an instance at runtime — a shield goes up, a status effect lands. The property name is a checked reference. Add <code>@Public</code> to also emit a <code>prop_&lt;Property&gt;_attach</code> event.

```ludic
program AttachHook {
  property Tag    { value: int = 0 }
  property Shield { amount: int = 0 }
  model Unit { Tag }

  @OnAttach(Shield) handler RaiseShield {            # fires when Shield is attached
    print(Shield.amount + 10)                        # 15 — reads the seeded amount
  }

  handler Seed phase Start { spawn Unit { Tag { value: 1 } } }

  handler AddShield phase Render {
    for (unit) in query [Unit] {
      attach Shield on self() { amount: 5 }          # triggers @OnAttach
    }
    quit()
  }
}
```
