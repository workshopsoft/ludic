---
id: annot-public
name: @Public
category: annotations
kind: annotation
tokens: @Public
sig: @Public @OnSpawn(Model) handler … { … }
tip: Promote a lifecycle hook to a public event other modules can listen for.
order: 50
---

<code>@Public</code> stacks in front of a lifecycle hook to also emit a well-named event at the same moment the hook fires, so other modules (or mods) can react without touching the original code. It turns a private hook into a public seam: <code>@Public @OnSpawn(Model)</code> emits <code>model_&lt;Model&gt;_spawn</code>, <code>@OnDespawn</code> emits <code>model_&lt;Model&gt;_despawn</code>, the property hooks emit <code>prop_&lt;Property&gt;_attach</code>/<code>_detach</code>/<code>_enable</code>/<code>_disable</code>, and <code>@OnStart</code>/<code>@OnQuit</code> emit <code>program_start</code>/<code>program_quit</code>. This is the same lowering the event system uses, so anyone can <code>@On</code> the generated event to extend behavior at that lifecycle point. Add it when a hook marks an extension point you want to keep open across a modular codebase.

```ludic
program PublicSpawn {
  property Health { current: int = 0, maximum: int = 100 }
  model Enemy { Health }

  @Public @OnSpawn(Enemy) handler InitEnemy {        # also emits model_Enemy_spawn
    Health.current = Health.maximum
  }

  @On(model_Enemy_spawn) handler AnnounceEnemy {     # another module hooks the public event
    print(1)                                         # 1 — reacts to every Enemy spawn
  }

  handler SpawnWave phase Start {
    spawn Enemy { Health { current: 0, maximum: 100 } }
  }
}
```
