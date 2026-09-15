bump: minor
type: feat
**Real OS threads behind `Job.*` and `Sync.*`** — `Job.parallel_for` runs work across every core.

- **`fn name`** — an expression naming a top-level function as a value, for a worker's entry point.
  No closures: the data a worker needs is passed in.
- **`Job.parallel_for(count, fn work, ctx)`** — `work(i, ctx)` for every `i` in `[0, count)`, split
  into chunks across a worker pool (one thread per core but one, pthreads or Win32) and the calling
  thread; returns when all are done. `Job.is_worker()` says whether code is on a pool thread.
- **`Sync.*` is thread-safe** — mutexes are real mutexes, atomics are compare-and-swap, channels are
  guarded, and `Sync.cpu_count()` reports the machine's cores.
- **A worker must not change the world** — `spawn` and `despawn` on a pool thread stop the program with
  a located message.
