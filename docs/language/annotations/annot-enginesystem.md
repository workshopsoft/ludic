---
id: annot-enginesystem
name: @EngineSystem
category: annotations
kind: annotation
tokens: @EngineSystem
sig: "@EngineSystem(Component, Phase) function esys_name() { … }"
tip: Register a package's engine-owned system so the frame loop runs it each phase.
order: 60
---

<code>@EngineSystem(Component, Phase)</code> marks a function as an engine-owned system: the compiler adds it to the engine-system registry, and the frame loop calls it every <code>Phase</code> — after the game's own handlers — whenever the named <code>Component</code> is present in the program. It is the package-declarable form of the built-in engine systems (the ones that advance <code>SpriteAnim</code>/<code>Motion</code>/<code>Light2D</code>), so a third-party controller ships a system the same way the standard library does, with no compiler edit. The function reads and writes components by name through the reflection ABI, so it stays layout-independent and additive: a build that never declares the component compiles byte-for-byte the same. Phases are <code>Input</code>, <code>FixedUpdate</code>, <code>Update</code>, <code>LateUpdate</code> and <code>Render</code>.

```ludic
program EngineSystemDemo {
  property Score { value: int = 0 }
  model Player { Score }

  @EngineSystem(Score, Update) function esys_score() -> void {   # runs every Update
    let P = world_prop_id("Score")
    let e = world_query_next(P, 0)
    if e >= 0 { world_set(e, P, 0, world_get(e, P, 0) + 1) }     # advance by name
  }

  @OnSpawn(Player) handler Init { }
  handler Boot phase Start { let e = world_spawn(world_model_id("Player")) }
  handler Run phase Update {
    let P = world_prop_id("Score")
    print(world_get(world_query_next(P, 0), P, 0))               # grows each frame
    quit()
  }
}
```
