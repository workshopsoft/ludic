---
id: job-defer
name: Job.defer
category: job
kind: namespace-method
tokens: Job.defer
sig: Job.defer() -> Job
tip: A future you resolve yourself later.
order: 0
ns: Job
member: defer
---

A future you resolve yourself later.

```ludic
let job = Job.defer()
Job.fulfill(job, 42)
```
