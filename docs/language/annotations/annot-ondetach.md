---
id: annot-ondetach
name: @OnDetach
category: annotations
kind: annotation
tokens: @OnDetach
sig: @OnDetach(Property) handler Name { … }
tip: Run a handler when a property is structurally detached from a live instance.
order: 50
---

<code>@OnDetach(Property)</code> is the teardown counterpart to <code>@OnAttach</code>: it fires when the named property is structurally removed from a live instance with <code>detach P on e</code>. The hook runs <b>before</b> the property's presence flag clears, so its body can still read the outgoing field values one last time — useful for releasing whatever the property was tracking or logging its final state. It is distinct from <code>@OnDisable</code>, which pauses a property while keeping its data; detach actually destroys the property's presence on the instance. Add <code>@Public</code> to also emit a <code>prop_&lt;Property&gt;_detach</code> event.

```ludic
program DetachHook {
  property Tag    { value: int = 0 }
  property Shield { amount: int = 0 }
  model Unit { Tag }

  @OnDetach(Shield) handler DropShield {             # fires as Shield is removed
    print(Shield.amount + 20)                        # 25 — reads the outgoing amount
  }

  handler Seed phase Start {
    spawn Unit { Tag { value: 1 } }
    for (unit) in query [Unit] { attach Shield on self() { amount: 5 } }
  }

  handler RemoveShield phase Render {
    for (shield) in query [Shield] {
      detach Shield on self()                         # triggers @OnDetach
    }
    quit()
  }
}
```
