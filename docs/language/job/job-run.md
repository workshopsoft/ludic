---
id: job-run
name: Job.run
category: job
kind: namespace-method
tokens: Job.run
sig: Job.run(kind, arg) -> Job
tip: Start a background compute job.
order: 1
ns: Job
member: run
---

Start a background compute job.

```ludic
let job = Job.run(1, 100)   # 1 = sum 1..arg, 2 = fib, 3 = count primes
Job.pump(0)
```
