---
id: sync-get
name: Sync.get
category: sync
kind: namespace-method
tokens: Sync.get
sig: Sync.get(atomic) -> int
tip: Read the counter.
order: 5
ns: Sync
member: get
---

Read the counter.

```ludic
let a = Sync.atomic()
let v = Sync.get(a)
```
