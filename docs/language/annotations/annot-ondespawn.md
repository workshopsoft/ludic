---
id: annot-ondespawn
name: @OnDespawn
category: annotations
kind: annotation
tokens: @OnDespawn
sig: @OnDespawn(Model, reason: r) handler Name { … }
tip: Run a handler when a model instance is torn down, optionally knowing why.
order: 50
---

<code>@OnDespawn(Model)</code> is the teardown counterpart to <code>@OnSpawn</code>: it fires once for each instance of the named model as it is removed, whether by an in-world <code>despawn</code> or at program shutdown, and its body still reads the instance's outgoing field values before they are gone. With the optional <code>reason: r</code> binding it becomes reason-carrying teardown — <code>r</code> is bound to an <code>EndReason</code> the compiler passes at each teardown site (an in-world despawn passes <code>EndReason.Despawned</code>, program exit passes <code>EndReason.Quit</code>) so one hook can branch on <b>why</b> the instance is ending, the way Unreal's <code>EndPlay(reason)</code> does. Every still-live instance's hook fires at quit, which makes "no silent deaths" real: drop loot on a real death but skip it when the app is simply closing. Add <code>@Public</code> to also emit a <code>model_&lt;Model&gt;_despawn</code> event.

```ludic
program DespawnHook {
  property Health { current: int = 0 }
  property Loot   { gold: int = 0 }
  model Enemy { Health, Loot }

  @OnDespawn(Enemy, reason: teardown_reason) handler DropLoot {
    match teardown_reason {
      EndReason.Quit => { }                            # app closing — do not drop loot
      _              => { print(Loot.gold) }          # died in-world — award the gold
    }
  }

  handler SpawnWave phase Start { spawn Enemy { Health { current: 10 }, Loot { gold: 25 } } }

  handler KillOne phase Render {
    for (Health) in query [Health, {Enemy}] { despawn self() }   # prints 25
    quit()
  }
}
```
