---
id: annot-computed
name: @Computed
category: annotations
kind: annotation
tokens: @Computed
sig: @Computed on a property field
tip: A derived field expanded inline wherever it is read, never stored.
order: 1
---

<code>@Computed</code> marks a property field as <b>derived</b>: instead of occupying a slot in the world, its expression is expanded inline at every site that reads it, so it is recomputed on demand and never takes storage. Use it for values that are a pure function of other fields — a total, a midpoint, a scaled amount — where storing them would risk going stale. Because a computed field has no backing storage it cannot be assigned to, and it is not something you replicate: it costs nothing on the wire and is simply recomputed on each peer. Reach for it when a value should always be consistent with its inputs and you would otherwise have to remember to recompute it by hand.

```ludic
program DerivedStats {
  property Health {
    current: int = 100,
    maximum: int = 100,
    @Computed missing: int = maximum - current    # never stored; expanded where read
  }
  model Player { Health }

  handler ReportDamage phase Update {
    for (Health) in query [Health] {
      Health.current = 70
      print(Health.missing)                        # 30 — recomputed from current and maximum
    }
  }

  handler SpawnPlayer phase Start {
    spawn Player { Health { current: 100, maximum: 100 } }
  }
}
```
