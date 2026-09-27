---
id: job-parallel_for
name: Job.parallel_for
category: job
kind: namespace-method
tokens: Job.parallel_for
sig: Job.parallel_for(count, work, ctx) -> void
tip: Run work(i, ctx) for every i in [0, count) across all cores; returns when every call is done.
order: 16
ns: Job
member: parallel_for
---

Run `work(i, ctx)` for every `i` in `[0, count)` on real OS threads, and return when every call has
finished. The indices are split into chunks shared by a worker pool (one thread per core but one,
started on first use) and the calling thread, so each index runs exactly once, in no particular order.

`work` is a top-level function taking `(i: int, ctx)`, named with `fn`; `ctx` is whatever it computes
on (`words`, `bytes` or a `pointer`). A worker computes on what it was handed and writes only its own
index's results: it must not `spawn`, `despawn`, `push` onto a list another thread can see, or use
Http or Audio. `spawn` and `despawn` on a worker stop the program with a located message. Shared
counters go through `Sync.add`, shared totals behind a `Sync.mutex`. A worker may take states, but
only to read them: every thread runs it at once, so a worker that takes one as `mut` is refused at
compile time (a result goes into `ctx`, a count through a `Sync` handle kept in the state).

```ludic
program Squares {
  function square(i: int, out: words) -> void { out[i] = i * i }

  entry {
    let sq = words(20000)
    Job.parallel_for(20000, fn square, sq)
    print(sq[141])
  }
}
```
