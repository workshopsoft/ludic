---
id: job-pending
name: Job.pending
category: job
kind: namespace-method
tokens: Job.pending
sig: Job.pending() -> int
tip: How many jobs are still unresolved.
order: 12
ns: Job
member: pending
---

How many jobs are still unresolved.

```ludic
let left = Job.pending()   # a ready-made loading-screen counter
```
