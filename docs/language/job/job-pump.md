---
id: job-pump
name: Job.pump
category: job
kind: namespace-method
tokens: Job.pump
sig: Job.pump(budget) -> int
tip: Advance background jobs; collect results.
order: 5
ns: Job
member: pump
---

Advance background jobs; collect results.

```ludic
let job = Job.run(1, 1000)
Job.pump(64)   # spend up to 64 steps this frame (0 = finish all)
```
