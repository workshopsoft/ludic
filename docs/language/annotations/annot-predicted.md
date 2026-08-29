---
id: annot-predicted
name: @Predicted
category: annotations
kind: annotation
tokens: @Predicted
sig: @Predicted handler Name { … }
tip: Run a control handler on the owning client speculatively and on the server authoritatively.
order: 50
---

<code>@Predicted</code> marks a control handler that runs in two places: speculatively on the client that <b>owns</b> the affected instance, so local input feels instant, and authoritatively on the server, whose result reconciles the client if the two diverge. It is the responsive-control role from Quake-style client-prediction, named for the netcode behavior (owner-predicts plus server-authoritative plus reconcile) rather than the machine, and it matches Unity's <code>GhostMode.Predicted</code> so the concept transfers. Prediction is explicit — Ludic never silently predicts — and it only applies to instances of an <code>@Owned</code> model, since the dispatch reads <code>is_owner</code> to decide whether the local client should run it. Use it for the owning player's movement and actions; leave authority-only rules on <code>@Server</code>.

```ludic
program PredictedMovement {
  @Sync property Position { column: int = 0, row: int = 0 }
  @Owned model Player { @Sync Position }

  @Predicted handler MovePlayer phase Input {        # owner predicts, server reconciles
    let pressed = Input.key()
    for (Position) in query [Position, {Player}] {
      if pressed == 'd' { Position.column = Position.column + 1 }
    }
  }

  handler SpawnPlayer phase Start {
    spawn Player { Position { column: 0, row: 0 } }
  }
}
```
