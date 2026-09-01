---
id: job-failed
name: Job.failed
category: job
kind: namespace-method
tokens: Job.failed
sig: Job.failed(handle) -> bool
tip: Did the job fail?
order: 8
ns: Job
member: failed
---

Did the job fail?

```ludic
let job = Job.defer()
Job.fail(job, 9)
let bad = Job.failed(job)
```
