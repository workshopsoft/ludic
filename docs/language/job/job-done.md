---
id: job-done
name: Job.done
category: job
kind: namespace-method
tokens: Job.done
sig: Job.done(handle) -> bool
tip: Has the job resolved (any outcome)?
order: 6
ns: Job
member: done
---

Has the job resolved (any outcome)?

```ludic
let job = Job.defer()
Job.fulfill(job, 1)
let finished = Job.done(job)
```
