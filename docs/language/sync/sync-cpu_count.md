---
id: sync-cpu_count
name: Sync.cpu_count
category: sync
kind: namespace-method
tokens: Sync.cpu_count
sig: Sync.cpu_count() -> int
tip: The machine's logical cores (1 to 64); Job.parallel_for uses one thread per core.
order: 14
ns: Sync
member: cpu_count
---

The machine's logical cores, from 1 to 64. `Job.parallel_for` runs on that many threads: a pool of
one per core but one, plus the caller.

```ludic
let lanes = Sync.cpu_count()
```
