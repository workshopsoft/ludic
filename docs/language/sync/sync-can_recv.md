---
id: sync-can_recv
name: Sync.can_recv
category: sync
kind: namespace-method
tokens: Sync.can_recv
sig: Sync.can_recv(channel) -> bool
tip: Is there a value waiting?
order: 12
ns: Sync
member: can_recv
---

Is there a value waiting?

```ludic
let ch = Sync.channel()
let has = Sync.can_recv(ch)
```
