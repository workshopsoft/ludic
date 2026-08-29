---
id: fn-apply
name: apply
category: networking
kind: builtin
tokens: apply
sig: apply(target, buf, len)
tip: Fold received @Sync bytes back onto a model instance.
order: 50
---

<code>apply</code> is the exact inverse of <code>serialize</code>: it reads <code>len</code> bytes from <code>buf</code> and copies each value back into the replicable-and-participating fields of the target model instance, in the same member-then-field order the serializer packed them. It is compiler-generated and dispatches on the instance's model, so it only touches synced fields — an unsynced field keeps whatever value it already held. Use it after <code>net_poll</code> to reconcile a client to the authority's state, or after a rollback to restore a snapshot you took with <code>serialize</code>. The buffer must have come from a serializer for a matching model, or the layout will not line up.

Parameters:
- `target` — the model instance (an `entity`) to write the fields onto
- `buf` — the source buffer holding serialized bytes
- `len` — the number of bytes in `buf` to read

```ludic
program ReconcilePlayer {
  @Sync property Position { column: int = 0, row: int = 0 }
  @Owned model Player { @Sync Position }

  entry {
    spawn Player { Position { column: 3, row: 4 } }
    for (Position) in query [Position, {Player}] {
      let player_id = self()
      let snapshot_buffer = bytes(64)
      let byte_count = serialize(player_id, snapshot_buffer)     # save authoritative state
      Position.column = 999                                      # a mispredicted divergence
      apply(player_id, snapshot_buffer, byte_count)             # reconcile back to the snapshot
      print(Position.column)                                     # 3 — restored
    }
  }
}
```
