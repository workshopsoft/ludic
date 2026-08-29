---
id: kw-disable
name: disable
category: ecs
kind: keyword
tokens: disable
sig: disable Prop on entity
tip: Deactivate a property, model, or handler without destroying its data.
order: 5
---

<code>disable</code> switches something off while keeping it intact, so a later `enable` brings it back untouched — a reversible pause rather than a destruction. `disable Prop on instance` clears that instance's has-flag for the property, so queries stop matching it, but the field values stay in storage. It has three scopes: one property on one instance (`disable Shield on self()`), a whole model (`disable Enemy` drops all its instances out of every query), and a handler (`disable AiThink` stops it running each phase until re-enabled). Each toggle is a single flag flip, so nothing is copied or freed. Disabling a property fires any `@OnDisable(Prop)` hook. Contrast with `detach`, which structurally removes a property (a later `attach` re-seeds fresh fields).

```ludic
program Stealth {
  property Position { column: int = 0, row: int = 0 }
  property Velocity { delta_x: int = 0, delta_y: int = 0 }
  model Enemy { Position, Velocity }

  handler Boot phase Start {
    spawn Grunt { Position { column: 4, row: 4 }; Velocity { delta_x: 1 } }
  }

  handler FreezeEnemies phase Update {
    if Input.key() == 'p' {
      for (velocity) in query [Velocity, {Enemy}] { disable Velocity on self() }
    }
  }
}
```
