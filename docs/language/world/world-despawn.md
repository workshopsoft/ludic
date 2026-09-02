---
id: world-despawn
name: World.despawn
category: world
kind: namespace-method
tokens: World.despawn
sig: World.despawn(entity)
tip: Despawn an entity by id — runs its @OnDespawn hooks and frees the slot.
order: 16
ns: World
member: despawn
---

Despawns an entity by id: it runs the entity's model <code>@OnDespawn</code> hook (with reason <code>Despawned</code>), sweeps any entity-scoped event listeners, and frees the slot back to the pool for reuse — the reflective, by-id form of the <code>despawn</code> statement. Use it from a system that has an entity id in hand (the engine world-bounds kill policy uses it, #84) or wherever you would write <code>despawn e</code> but only have the id.

```ludic
program Demo {
  property Mob { hp: int = 0 }
  model M { Mob }
  entry {
    spawn M { Mob { hp: 1 } }
    let pm = World.prop_id("Mob")
    let e = World.query_next(pm, 0)
    World.despawn(e)
    print(World.query_next(pm, 0))     # -1 — none left
  }
}
```
