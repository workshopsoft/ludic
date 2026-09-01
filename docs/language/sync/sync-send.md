---
id: sync-send
name: Sync.send
category: sync
kind: namespace-method
tokens: Sync.send
sig: Sync.send(channel, value) -> bool
tip: Enqueue a value (false if full).
order: 10
ns: Sync
member: send
---

Enqueue a value (false if full).

```ludic
let ch = Sync.channel()
let sent = Sync.send(ch, 42)
```
