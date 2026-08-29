---
id: fn-net_poll
name: net_poll
category: networking
kind: builtin
tokens: net_poll
sig: net_poll(buf, cap) -> int
tip: Receive queued bytes from the transport; returns the byte count.
order: 1
---

<code>net_poll</code> copies up to <code>cap</code> waiting bytes into <code>buf</code> and returns how many actually arrived, or <code>0</code> when nothing is queued. It is the read half of the transport seam and the counterpart to <code>net_send</code>; each poll yields one datagram, so drain in a loop until it returns <code>0</code>. Once you have the bytes you fold them back into a model instance with the generated <code>apply</code> — for a self-describing frame, write the entity id into the first word on send and read it back here before applying. Like <code>net_send</code>, this is the freedom layer beneath <code>@Sync</code>; most games never call it directly.

Parameters:
- `buf` — the destination buffer to copy received bytes into
- `cap` — the maximum number of bytes to accept this call

```ludic
program ReceivePlayer {
  @Sync property Position { column: int = 0, row: int = 0 }
  @Owned model Player { @Sync Position }

  entry {
    spawn Player { Position { column: 0, row: 0 } }
    let incoming_bytes = words(512)
    var received_count = net_poll(incoming_bytes, 2048)
    while received_count > 0 {
      let target_id = incoming_bytes[0]                          # entity id led the frame
      apply(target_id, offset(incoming_bytes, 4), received_count - 4)
      received_count = net_poll(incoming_bytes, 2048)            # next datagram, if any
    }
  }
}
```
