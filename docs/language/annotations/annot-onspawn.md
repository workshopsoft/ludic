---
id: annot-onspawn
name: @OnSpawn
category: annotations
kind: annotation
tokens: @OnSpawn
sig: @OnSpawn(Model) handler Name { … }
tip: Run a handler once each time an instance of a model is spawned.
order: 50
---

<code>@OnSpawn(Model)</code> turns a handler into a birth hook: it fires once for each newly <code>spawn</code>ed instance of the named model, right after its properties are seeded. The body runs in the context of that fresh instance, so it can read and adjust the instance's fields by property name to finish initialization — seed derived state, register the instance, play a spawn effect. The model name is a checked reference, so a typo is a compile error rather than a silently dead hook. Its teardown counterpart is <code>@OnDespawn</code>; add <code>@Public</code> to also emit a <code>model_&lt;Model&gt;_spawn</code> event other modules can listen for.

```ludic
program SpawnHook {
  property Health { current: int = 0, maximum: int = 100 }
  model Enemy { Health }

  @OnSpawn(Enemy) handler InitEnemy {                # fires per new Enemy instance
    Health.current = Health.maximum                  # start every enemy at full health
    print(Health.current)                            # 100
  }

  handler SpawnWave phase Start {
    spawn Enemy { Health { current: 0, maximum: 100 } }
  }
}
```
