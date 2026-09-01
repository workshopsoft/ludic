---
id: sync-add
name: Sync.add
category: sync
kind: namespace-method
tokens: Sync.add
sig: Sync.add(atomic, delta) -> int
tip: Add to the counter; return the new value.
order: 7
ns: Sync
member: add
---

Add to the counter; return the new value.

```ludic
let a = Sync.atomic()
let total = Sync.add(a, 1)
```
