---
id: annot-owned
name: @Owned
category: annotations
kind: annotation
tokens: @Owned
sig: @Owned model Name { … }
tip: Give a model a network owner slot so its instances can be assigned to a peer.
order: 50
---

<code>@Owned</code> declares that every instance of a model carries a network owner — it adds an owner slot to the model (the runtime's <code>@L_owner</code> array), which the builtins <code>owner</code>, <code>set_owner</code>, and <code>is_owner</code> read and assign. A fresh instance starts unowned (<code>-1</code>) until the authority assigns it. Ownership is what gates who may write <code>@Sync(to: owner)</code> fields and who runs <code>@Predicted</code> control handlers, and it is stored in the world snapshot so it round-trips through replication and rollback. Mark the models that represent a player's avatar or units; leave shared scenery unowned.

```ludic
program OwnedModel {
  @Sync property Position { column: int = 0, row: int = 0 }
  @Owned model Player { @Sync Position }              # each Player instance has an owner slot

  entry {
    spawn Player { Position { column: 5, row: 6 } }
    for (Position) in query [Position, {Player}] {
      let player_id = self()
      print(owner(player_id))          # -1 — unowned until assigned
      set_owner(player_id, 0)
      print(is_owner(player_id))       # 1  — the local peer now owns it
    }
  }
}
```
