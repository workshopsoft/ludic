---
id: sync-atomic
name: Sync.atomic
category: sync
kind: namespace-method
tokens: Sync.atomic
sig: Sync.atomic() -> int
tip: Create an atomic counter (starts at 0).
order: 4
ns: Sync
member: atomic
---

Create an atomic counter (starts at 0).

Returns an atomic-counter handle. Read it with <code>Sync.get</code>, write with <code>Sync.set</code>, accumulate with <code>Sync.add</code>, and swap conditionally with <code>Sync.cas</code>.

```ludic
let a = Sync.atomic()
```
