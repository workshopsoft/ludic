bump: minor
type: feature
**A `Job.parallel_for` worker may read a state but not change one.** Every pool thread runs the
worker at once, and the runtime hands each call the same state, so a worker that took a state as
`mut` raced on it with nothing to say so. The compiler now refuses it (`fn bump: a worker runs on
every core at once, so it may read CountState but not change it`): a result goes into `ctx`, a
shared count through a `Sync` handle kept in the state. A function's signature already says what it
touches, so this is the whole check - the same one a parallel scheduler needs to run two systems at
once. `examples/library/threads.ludic` keeps its total in the words it hands the worker.
