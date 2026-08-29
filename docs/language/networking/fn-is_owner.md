---
id: fn-is_owner
name: is_owner
category: networking
kind: builtin
tokens: is_owner
sig: is_owner(target) -> bool
tip: Whether the local peer owns a model instance.
order: 50
---

<code>is_owner</code> reports whether the local peer owns a given model instance — it compares the instance's stored owner (see <code>owner</code>) against <code>local_id</code> and returns the result. It only makes sense for instances of an <code>@Owned</code> model, and it is what <code>@Predicted</code> handler dispatch consults to decide whether the owning client should run a control handler speculatively. Prefer this over reading <code>owner</code> and comparing ids yourself. A freshly spawned, unowned instance returns false everywhere until the authority assigns it with <code>set_owner</code>.

Parameters:
- `target` — the model instance (an `entity`) to test

```ludic
program CheckOwnership {
  @Sync property Position { column: int = 0, row: int = 0 }
  @Owned model Player { @Sync Position }

  entry {
    spawn Player { Position { column: 5, row: 6 } }
    for (Position) in query [Position, {Player}] {
      let player_id = self()
      set_owner(player_id, 7)
      print(is_owner(player_id))       # 0 — local id 0 does not own peer 7's instance
      set_owner(player_id, 0)
      print(is_owner(player_id))       # 1 — now the local peer owns it
    }
  }
}
```
