---
id: annot-ondisable
name: @OnDisable
category: annotations
kind: annotation
tokens: @OnDisable
sig: @OnDisable(Property) handler Name { … }
tip: Run a handler when a property is paused (disabled) on an instance.
order: 50
---

<code>@OnDisable(Property)</code> fires when a present property is paused with <code>disable P on e</code>. Disabling keeps the property's data intact and simply stops it from participating — the logical "off" switch — so this hook is the moment a capability goes dormant, not the moment it is destroyed (that is <code>@OnDetach</code>). The body runs in the instance's context and can read the fields before they go quiet, which is handy for cleaning up an effect the property was driving. It pairs with <code>@OnEnable</code> for capabilities that toggle on and off repeatedly. Add <code>@Public</code> to also emit a <code>prop_&lt;Property&gt;_disable</code> event.

```ludic
program DisableHook {
  property Tag    { value: int = 0 }
  property Shield { amount: int = 0 }
  model Unit { Tag, Shield }

  @OnDisable(Shield) handler ShieldDown {            # fires when Shield is disabled
    print(Shield.amount)                             # 5 — data is retained, just paused
  }

  handler Seed phase Start { spawn Unit { Tag { value: 1 }, Shield { amount: 5 } } }

  handler Deactivate phase Render {
    for (unit) in query [Unit] {
      disable Shield on self()                        # triggers @OnDisable
    }
    quit()
  }
}
```
