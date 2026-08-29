---
id: fn-world_load
name: world_load
category: ecs
kind: builtin
tokens: world_load
sig: world_load(buf, len)
tip: Restore the whole world from a serialized byte buffer.
order: 50
---

<code>world_load</code> restores the ECS world from a byte buffer previously produced by `world_save`, replacing the current world with the snapshot's instances and their fields. You pass the buffer and the number of valid bytes in it (the count `world_save` returned), and the world is rebuilt in place; it returns nothing. This is the low-level, buffer-based counterpart of `world_save` — the pair a mod or tool uses to move a whole world across the ABI or between storage. For a simple whole-game load from the default slot, the higher-level `load()` builtin is usually enough.

Parameters:
- `buf` — the source byte buffer holding a snapshot
- `len` — the number of valid bytes in `buf`

```ludic
program SnapshotRoundTrip {
  property Position { column: int = 0, row: int = 0 }
  model Enemy { Position }

  var snapshot_length: int = 0

  handler Boot phase Start {
    spawn Grunt { Position { column: 3, row: 3 } }
  }

  handler RoundTrip phase Update {
    let buffer = bytes(4096)
    if Input.key() == 's' { snapshot_length = world_save(buffer) }
    if Input.key() == 'l' { world_load(buffer, snapshot_length) }
  }
}
```
