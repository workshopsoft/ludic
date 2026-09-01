---
id: job-cancelled
name: Job.cancelled
category: job
kind: namespace-method
tokens: Job.cancelled
sig: Job.cancelled(handle) -> bool
tip: Was the job cancelled?
order: 9
ns: Job
member: cancelled
---

Was the job cancelled?

```ludic
let job = Job.defer()
Job.cancel(job)
let stopped = Job.cancelled(job)
```
