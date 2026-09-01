---
id: sync-mutex
name: Sync.mutex
category: sync
kind: namespace-method
tokens: Sync.mutex
sig: Sync.mutex() -> int
tip: Create a cooperative lock.
order: 0
ns: Sync
member: mutex
---

Create a cooperative lock.

Creates a mutex handle for guarding a critical section. On the deterministic single-threaded runtime it never blocks — pair <code>Sync.lock</code> / <code>Sync.unlock</code> around the section, or probe with <code>Sync.try_lock</code>.

```ludic
let m = Sync.mutex()
```
