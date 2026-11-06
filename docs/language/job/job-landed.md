---
id: job-landed
name: Job.landed
category: job
kind: namespace-method
tokens: Job.landed
sig: Job.landed(flag) -> bool
tip: Has the work spawned with this flag returned?
order: 18
ns: Job
member: landed
---

`true` once the work queued by <a href="job-spawn.html"><code>Job.spawn</code></a> with this `flag` has
returned, so everything it wrote is there to read. It never waits: ask once a frame, and install the
results on the main thread when it answers `true`.

```ludic
program Poll {
  property Work {
    out: int = 0
  }
  function work(i: int, w: Work) -> void { w.out = i + 1 }

  entry {
    let w = new Work
    let flag = words(1)
    Job.spawn(fn work, 41, w, flag)
    while not Job.landed(flag) { }
    print(w.out)
  }
}
```
