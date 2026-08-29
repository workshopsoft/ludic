---
id: fn-owner
name: owner
category: networking
kind: builtin
tokens: owner
sig: owner(target) -> int
tip: Read a model instance's network owner id.
order: 50
---

<code>owner</code> returns the network peer id that owns a model instance, or <code>-1</code> when the instance is unowned. It only means anything for instances of an <code>@Owned</code> model, which is what gives the model its owner slot (the runtime's <code>@L_owner</code> array); a fresh instance starts unowned until the authority assigns it with <code>set_owner</code>. Ownership is part of the world snapshot, so it round-trips through replication and rollback. Read it when you need the raw id; use <code>is_owner</code> when you only need to know whether the local peer owns the instance.

Parameters:
- `target` — the model instance (an `entity`) whose owner is read

```ludic
program InspectOwner {
  @Sync property Position { column: int = 0, row: int = 0 }
  @Owned model Player { @Sync Position }

  entry {
    spawn Player { Position { column: 5, row: 6 } }
    for (Position) in query [Position, {Player}] {
      let player_id = self()
      print(owner(player_id))          # -1 — a fresh instance is unowned
      set_owner(player_id, 7)
      print(owner(player_id))          # 7  — the authority assigned peer 7
    }
  }
}
```
