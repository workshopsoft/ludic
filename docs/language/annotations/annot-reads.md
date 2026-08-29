---
id: annot-reads
name: @Reads
category: annotations
kind: annotation
tokens: @Reads
sig: @Reads(Property)
tip: Declare that a handler reads a property — an analysis and scheduling hint.
order: 50
---

<code>@Reads(Property)</code> declares that a handler reads the named property. It is an analysis hint: it documents a handler's data dependencies so tooling and scheduling can reason about which handlers touch which state — for example, to tell whether two handlers can run without conflict. It does not itself bind fields the way <code>@Queries</code> does, nor does it grant access; it annotates intent alongside the handler's actual query. Pair it with <code>@Writes</code> to spell out the full read/write footprint of a handler. Keep the named property real so the declared footprint matches what the body does.

```ludic
program ReadFootprint {
  property Health { current: int = 100 }
  property Score  { total: int = 0 }
  model Player { Health, Score }

  @Reads(Health)                                     # declares the read dependency
  handler ReportLowHealth phase Update {
    for (Health) in query [Health, {Player}] {
      if Health.current < 25 { print(Health.current) }
    }
  }

  handler SpawnPlayer phase Start {
    spawn Player { Health { current: 20 }, Score { total: 0 } }
  }
}
```
