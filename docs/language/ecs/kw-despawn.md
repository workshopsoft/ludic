---
id: kw-despawn
name: despawn
category: ecs
kind: keyword
tokens: despawn
sig: despawn entity
tip: Remove a model instance from the world, firing any @OnDespawn hooks.
order: 1
---

A <code>despawn</code> removes a model instance from the world, freeing its slot and firing any `@OnDespawn` lifecycle hooks for its kind. The most common form is `despawn self()` inside a query loop, which removes the instance currently being visited. Because queries iterate lazily by ascending id rather than from a frozen snapshot, despawning the current instance — or one already visited — is safe and will not disturb the walk. Despawning is how the moving parts of a game leave: an enemy that reached zero health, a projectile that flew off screen, or every instance of a kind during a reset.

```ludic
program Cleanup {
  property Position { column: int = 0, row: int = 0 }
  property Health   { current: int = 100, maximum: int = 100 }
  model Enemy { Position, Health }

  handler Boot phase Start {
    spawn Grunt { Position { column: 3, row: 3 }; Health { current: 0 } }
  }

  handler RemoveDefeated phase LateUpdate {
    for (health) in query [Health, {Enemy}] {
      if health.current <= 0 { despawn self() }
    }
  }
}
```
