---
id: job-cancel
name: Job.cancel
category: job
kind: namespace-method
tokens: Job.cancel
sig: Job.cancel(handle) -> void
tip: Cancel a job before it finishes.
order: 4
ns: Job
member: cancel
---

Cancel a job before it finishes.

```ludic
let job = Job.defer()
Job.cancel(job)
```
