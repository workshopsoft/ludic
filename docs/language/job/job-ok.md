---
id: job-ok
name: Job.ok
category: job
kind: namespace-method
tokens: Job.ok
sig: Job.ok(handle) -> bool
tip: Did the job succeed?
order: 7
ns: Job
member: ok
---

Did the job succeed?

```ludic
let job = Job.defer()
Job.fulfill(job, 1)
let good = Job.ok(job)
```
