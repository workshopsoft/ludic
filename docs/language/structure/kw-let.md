---
id: kw-let
name: let
category: structure
kind: keyword
tokens: let
sig: let name = value
tip: An immutable binding — the default choice for a value that never changes.
order: 7
---

A <code>let</code> introduces an <b>immutable</b> binding: once set, reassigning it (`name = …`) is a compile error. Reach for `let` by default and only switch to `var` when a value genuinely needs to change — it makes intent obvious and catches accidental writes. Immutability is of the <b>binding</b>, not the object it points at: a `let` that holds a property record or a slice still lets you mutate through it (`node.current = 5`), it just cannot be repointed at a different object. Bindings inside a body are locals scoped to their block.

```ludic
program Damage {
  property Health { current: int = 100, maximum: int = 100 }
  model Enemy { Health }

  handler Boot phase Start {
    spawn Grunt { Health { current: 40 } }
  }

  handler ApplyHit phase Update {
    let incoming_damage = 12
    for (health) in query [Health, {Enemy}] {
      let survivor = health.current - incoming_damage
      health.current = survivor
    }
  }
}
```
