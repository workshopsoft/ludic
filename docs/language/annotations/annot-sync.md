---
id: annot-sync
name: @Sync
category: annotations
kind: annotation
tokens: @Sync
sig: @Sync property … / @Owned
tip: Mark fields as replicated and models as owned so the compiler generates networking.
order: 4
---

These are the two declarative switches at the top of Ludic's networking: <code>@Sync</code> says <b>what</b> replicates and <code>@Owned</code> says <b>who</b> owns an instance. Replication is opt-in at the field level and decided per model use-site — a field crosses the wire only when it is both replicable (marked <code>@Sync</code>, either on the field or via <code>@Sync property P</code> which marks every field of <code>P</code>) <b>and</b> participating (the model marks the component <code>@Sync</code>). So the same property can replicate in one model and not another, and there is no <code>@NoSync</code> because the surface is purely additive. From these marks the compiler generates the per-model <code>serialize</code>/<code>apply</code> codecs; <code>@Sync</code> on a non-POD-scalar field (like a <code>ptr</code>) is a compile error, since a machine-local pointer cannot cross the wire. <code>@Owned</code> adds the owner slot the ownership builtins and <code>@Predicted</code> read. See the dedicated <code>@Owned</code> page for ownership details.

```ludic
program SyncedWorld {
  @Sync property Position { column: int = 0, row: int = 0 }   # every field replicable
  property Health { @Sync current: int = 0, maximum: int = 0 } # only current replicable

  @Owned model Player { @Sync Position, @Sync Health }         # participates -> column,row,current
  model Scenery { Position }                                   # not @Sync here -> never replicates

  entry {
    spawn Player { Position { column: 3, row: 4 }, Health { current: 50, maximum: 100 } }
    for (Position, Health) in query [Position, Health, {Player}] {
      print(sync_size(self()))          # 12 = Position(8) + Health.current(4)
    }
  }
}
```
