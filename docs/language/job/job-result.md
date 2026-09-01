---
id: job-result
name: Job.result
category: job
kind: namespace-method
tokens: Job.result
sig: Job.result(handle) -> int
tip: The success value of a done job.
order: 10
ns: Job
member: result
---

The success value of a done job.

```ludic
let job = Job.defer()
Job.fulfill(job, 42)
let value = Job.result(job)
```
