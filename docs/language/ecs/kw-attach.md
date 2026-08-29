---
id: kw-attach
name: attach
category: ecs
kind: keyword
tokens: attach
sig: attach Prop on entity { overrides }
tip: Structurally add a property to a live model instance, seeding its fields.
order: 6
---

<code>attach</code> adds a property to a live model instance that did not have it, seeding the fields from their defaults plus any overrides in the `{ … }` block, and fires the property's `@OnAttach(Prop)` hook. It is a <b>structural</b> change — it changes what the instance <i>has</i> — as opposed to `enable`, which merely resumes a property the instance already carries. Attaching a property the instance already has is a no-op, so the hook only runs on a real transition. Use it to grant something new at runtime: give a player a shield pickup, tag an enemy as enraged, or add a component only some instances need.

```ludic
program Pickups {
  property Position { column: int = 0, row: int = 0 }
  property Shield   { amount: int = 0 }
  model Player { Position }

  handler Boot phase Start {
    spawn Hero { Position { column: 6, row: 6 } }
  }

  handler GrabShield phase Update {
    if Input.key() == ' ' {
      for (position) in query [Position, {Player}] {
        attach Shield on self() { amount: 3 }
      }
    }
  }
}
```
