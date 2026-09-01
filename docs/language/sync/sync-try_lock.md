---
id: sync-try_lock
name: Sync.try_lock
category: sync
kind: namespace-method
tokens: Sync.try_lock
sig: Sync.try_lock(mutex) -> bool
tip: Take the lock only if it is free.
order: 3
ns: Sync
member: try_lock
---

Take the lock only if it is free.

```ludic
let m = Sync.mutex()
let got = Sync.try_lock(m)
```
