---
id: fn-net_send
name: net_send
category: networking
kind: builtin
tokens: net_send
sig: net_send(peer, buf, len)
tip: Send raw bytes to a peer over the host's transport seam.
order: 0
---

<code>net_send</code> hands <code>len</code> bytes from <code>buf</code> to the numbered <code>peer</code>, and it is the write half of Ludic's transport seam. The transport itself is a host-provided seam rather than a fixed protocol — real UDP natively, WebRTC or WebSocket on the web, or a built-in loopback in tests — so the same game runs unchanged over any of them. This is the low-level freedom layer: you normally let <code>@Sync</code> and <code>@Owned</code> generate replication for you, and reach for <code>net_send</code> only when you drive the wire yourself, typically to ship a model instance's serialized <code>@Sync</code> fields. Pair it with <code>serialize</code> to fill the buffer and with <code>net_poll</code> on the far side to receive.

Parameters:
- `peer` — the destination peer id (a network id, e.g. `0` for the authority)
- `buf` — the source buffer holding the bytes to send
- `len` — how many bytes of `buf` to send

```ludic
program ReplicatePlayer {
  @Sync property Position { column: int = 0, row: int = 0 }
  @Owned model Player { @Sync Position }

  entry {
    spawn Player { Position { column: 3, row: 4 } }
    for (Position) in query [Position, {Player}] {
      let player_id = self()
      let outgoing_bytes = words(512)
      outgoing_bytes[0] = player_id                              # entity id in the first word
      let field_count = serialize(player_id, offset(outgoing_bytes, 4))
      net_send(0, outgoing_bytes, 4 + field_count)              # ship id + synced fields
    }
  }
}
```
