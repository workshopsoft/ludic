---
id: job-error
name: Job.error
category: job
kind: namespace-method
tokens: Job.error
sig: Job.error(handle) -> int
tip: The error code of a failed job.
order: 11
ns: Job
member: error
---

The error code of a failed job.

```ludic
let job = Job.defer()
Job.fail(job, 500)
let code = Job.error(job)
```
