---
id: sync-set
name: Sync.set
category: sync
kind: namespace-method
tokens: Sync.set
sig: Sync.set(atomic, value) -> void
tip: Store a value in the counter.
order: 6
ns: Sync
member: set
---

Store a value in the counter.

```ludic
let a = Sync.atomic()
Sync.set(a, 10)
```
