---
id: sync-unlock
name: Sync.unlock
category: sync
kind: namespace-method
tokens: Sync.unlock
sig: Sync.unlock(mutex) -> void
tip: Release the lock.
order: 2
ns: Sync
member: unlock
---

Release the lock.

```ludic
let m = Sync.mutex()
Sync.lock(m)
Sync.unlock(m)
```
