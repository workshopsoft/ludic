---
id: fn-set_owner
name: set_owner
category: networking
kind: builtin
tokens: set_owner
sig: set_owner(target, id)
tip: Assign a model instance's network owner.
order: 50
---

<code>set_owner</code> writes the owning peer id into a model instance's owner slot; it is how the authority hands an <code>@Owned</code> model instance to a client. Because ownership gates who may write <code>@Sync(to: owner)</code> fields and who runs <code>@Predicted</code> handlers, assignment is normally the server's job — a client assigning ownership to itself would defeat that. The value is stored in the world (the <code>@L_owner</code> array), so it survives snapshot, replication, and rollback. Pass the local peer id to make the local peer the owner, or any other peer's id to hand it off.

Parameters:
- `target` — the model instance (an `entity`) to assign
- `id` — the owning peer id to store

```ludic
program AssignOwnership {
  @Sync property Position { column: int = 0, row: int = 0 }
  @Owned model Player { @Sync Position }

  entry {
    spawn Player { Position { column: 5, row: 6 } }
    for (Position) in query [Position, {Player}] {
      let player_id = self()
      set_owner(player_id, 0)          # hand this instance to the local peer (id 0)
      print(is_owner(player_id))       # 1 — the local peer now owns it
    }
  }
}
```
