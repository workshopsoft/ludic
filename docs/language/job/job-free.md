---
id: job-free
name: Job.free
category: job
kind: namespace-method
tokens: Job.free
sig: Job.free(handle) -> void
tip: Release a job slot back to the pool.
order: 13
ns: Job
member: free
---

Release a job slot back to the pool.

```ludic
let job = Job.defer()
Job.fulfill(job, 1)
Job.free(job)
```
