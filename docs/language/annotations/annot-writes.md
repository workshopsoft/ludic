---
id: annot-writes
name: @Writes
category: annotations
kind: annotation
tokens: @Writes
sig: @Writes(Property)
tip: Declare that a handler writes a property — an analysis and scheduling hint.
order: 50
---

<code>@Writes(Property)</code> declares that a handler writes the named property. Like <code>@Reads</code> it is an analysis hint that documents a handler's data footprint so tooling and scheduling can reason about conflicts — two handlers that write the same property, or one that writes what another reads, cannot be reordered freely. It does not bind fields or grant access on its own; the handler still queries and mutates the property in its body as usual. Declaring reads and writes together makes a handler's effect on the world legible at a glance, which matters most in a large, modular codebase. Keep the named property accurate so the declared footprint matches the code.

```ludic
program WriteFootprint {
  property Health { current: int = 100 }
  model Enemy { Health }

  @Reads(Health) @Writes(Health)                     # full read/write footprint
  handler ApplyPoison phase Update {
    for (Health) in query [Health, {Enemy}] {
      Health.current = Health.current - 1
    }
  }

  handler SpawnEnemy phase Start {
    spawn Enemy { Health { current: 100 } }
  }
}
```
