---
id: job-fulfill
name: Job.fulfill
category: job
kind: namespace-method
tokens: Job.fulfill
sig: Job.fulfill(handle, value) -> void
tip: Resolve a pending job with a value.
order: 2
ns: Job
member: fulfill
---

Resolve a pending job with a value.

```ludic
let job = Job.defer()
Job.fulfill(job, 7)
```
