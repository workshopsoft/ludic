---
id: fn-world_save
name: world_save
category: ecs
kind: builtin
tokens: world_save
sig: world_save(buf) -> int
tip: Serialize the whole world into a buffer; returns the number of bytes written.
order: 50
---

<code>world_save</code> serializes the entire ECS world — every live instance, its kind, and all its property fields — into a byte buffer you provide, and returns the number of bytes written. It is the low-level, buffer-based form of a save: allocate a buffer with `bytes(n)` large enough to hold the snapshot, pass it in, and persist the written bytes (or hand them across the mod ABI). The exact count comes back so you know how much of the buffer is meaningful. Restore a snapshot later with `world_load`. For a simple whole-game save to the default slot, the higher-level `save()` builtin is usually enough.

Parameters:
- `buf` — the destination byte buffer, e.g. from `bytes(n)`

```ludic
program SnapshotOut {
  property Position { column: int = 0, row: int = 0 }
  model Enemy { Position }

  handler Boot phase Start {
    spawn Grunt { Position { column: 3, row: 3 } }
  }

  handler Persist phase Update {
    if Input.key() == 's' {
      let buffer = bytes(4096)
      let written = world_save(buffer)
      Screen.status(string(written))
    }
  }
}
```
