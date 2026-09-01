---
id: sync-cas
name: Sync.cas
category: sync
kind: namespace-method
tokens: Sync.cas
sig: Sync.cas(atomic, expect, next) -> bool
tip: Compare-and-set the counter.
order: 8
ns: Sync
member: cas
---

Compare-and-set the counter.

```ludic
let a = Sync.atomic()
let swapped = Sync.cas(a, 0, 1)
```
