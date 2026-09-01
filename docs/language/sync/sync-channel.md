---
id: sync-channel
name: Sync.channel
category: sync
kind: namespace-method
tokens: Sync.channel
sig: Sync.channel() -> int
tip: Create a bounded int FIFO channel.
order: 9
ns: Sync
member: channel
---

Create a bounded int FIFO channel.

Returns a channel handle — a fixed-capacity queue of ints for handing values between a producer and a consumer. Push with <code>Sync.send</code>, pull the oldest with <code>Sync.recv</code>, and check with <code>Sync.can_recv</code> / <code>Sync.len</code>.

```ludic
let ch = Sync.channel()
```
