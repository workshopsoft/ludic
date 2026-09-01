---
id: job-fail
name: Job.fail
category: job
kind: namespace-method
tokens: Job.fail
sig: Job.fail(handle, error) -> void
tip: Resolve a pending job as failed.
order: 3
ns: Job
member: fail
---

Resolve a pending job as failed.

```ludic
let job = Job.defer()
Job.fail(job, 404)
```
