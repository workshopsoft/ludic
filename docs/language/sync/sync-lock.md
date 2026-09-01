---
id: sync-lock
name: Sync.lock
category: sync
kind: namespace-method
tokens: Sync.lock
sig: Sync.lock(mutex) -> void
tip: Take the lock.
order: 1
ns: Sync
member: lock
---

Take the lock.

```ludic
let m = Sync.mutex()
Sync.lock(m)
```
