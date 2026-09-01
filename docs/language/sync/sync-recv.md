---
id: sync-recv
name: Sync.recv
category: sync
kind: namespace-method
tokens: Sync.recv
sig: Sync.recv(channel) -> int
tip: Dequeue the oldest value.
order: 11
ns: Sync
member: recv
---

Dequeue the oldest value.

```ludic
let ch = Sync.channel()
Sync.send(ch, 42)
let v = Sync.recv(ch)
```
