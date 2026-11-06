---
id: job-spawn
name: Job.spawn
category: job
kind: namespace-method
tokens: Job.spawn
sig: Job.spawn(work, i, ctx, flag) -> bool
tip: Queue work(i, ctx) on a background thread; returns at once.
order: 17
ns: Job
member: spawn
---

Queue `work(i, ctx)` on one of the background threads (two, started on first use) and return at
once, so the work runs while the frames go on. When `work` returns, `flag[0]` becomes `1`: poll it
each frame with <a href="job-landed.html"><code>Job.landed</code></a> and take the results on the main
thread. `flag` is a `words(1)` of its own; `Job.spawn` clears it to `0`. `ctx` is a record the work fills in. Returns `false` when the queue
is full (256 waiting): try again a later frame.

The rule is <a href="job-parallel_for.html"><code>Job.parallel_for</code></a>'s: `work` is a top-level
function taking `(i: int, ctx)`, named with `fn`, that computes on what `ctx` points at and writes
only there. It never reads or changes the world, a list or a registry the main thread uses meanwhile,
and never spawns or despawns. This is streaming's shape: a worker loads and builds, the main thread
installs.

```ludic
program Background {
  property Square {
    n: int = 0
    out: int = 0
  }
  function square(i: int, s: Square) -> void { s.out = s.n * s.n }

  entry {
    let s = new Square
    s.n = 12
    let flag = words(1)
    if Job.spawn(fn square, 0, s, flag) {
      while not Job.landed(flag) { }
      print(s.out)
    }
  }
}
```
