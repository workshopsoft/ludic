---
id: job-is_worker
name: Job.is_worker
category: job
kind: namespace-method
tokens: Job.is_worker
sig: Job.is_worker() -> bool
tip: True on a Job.parallel_for pool thread, false on the main thread.
order: 17
ns: Job
member: is_worker
---

True when the code is running on a `Job.parallel_for` pool thread, false on the main thread (and on
the calling thread while it takes its own share of a batch).

```ludic
if not Job.is_worker() { print("main thread") }
```
