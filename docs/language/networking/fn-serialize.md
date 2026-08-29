---
id: fn-serialize
name: serialize
category: networking
kind: builtin
tokens: serialize
sig: serialize(target, buf) -> int
tip: Pack a model instance's @Sync fields into a buffer; returns bytes written.
order: 50
---

<code>serialize</code> writes the replicated state of a model instance into <code>buf</code> and returns how many bytes it wrote. It is compiler-generated from the schema: it copies exactly the fields that are both <code>@Sync</code>-marked and participating in that instance's model, tightly packed in member-then-field order, and nothing else. This is the dispatcher over the per-model codecs, so it works for any spawned model whose fields sync. Use it to snapshot state before shipping it with <code>net_send</code> or before a rollback; the inverse is <code>apply</code>, which reads back the identical layout, and <code>sync_size</code> gives the byte count up front so you can size a buffer.

Parameters:
- `target` — the model instance (an `entity`) whose synced fields are read
- `buf` — the destination buffer the packed bytes are written into

```ludic
program SnapshotPlayer {
  @Sync property Position { column: int = 0, row: int = 0 }
  property Health { @Sync current: int = 0, maximum: int = 0 }
  @Owned model Player { @Sync Position, @Sync Health }

  entry {
    spawn Player { Position { column: 3, row: 4 }, Health { current: 50, maximum: 100 } }
    for (Position, Health) in query [Position, Health, {Player}] {
      let player_id = self()
      let snapshot_buffer = bytes(64)
      let byte_count = serialize(player_id, snapshot_buffer)     # pack column, row, current
      print(byte_count)                                          # 12 = Position(8) + Health.current(4)
    }
  }
}
```
