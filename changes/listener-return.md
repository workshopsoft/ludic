bump: patch
type: fix
**A `return` inside an `@On` listener ends that listener, not the whole dispatch.** Listeners are
compiled into one `@ev_<E>` function, and `return` branched to its exit: every listener declared
after the one that returned, and every foreign listener, never heard the event. The shape it
broke is the common one - a listener per kind that returns early for every kind but its own -
where only the first-declared kind was ever answered. `examples/events/answer.ludic` holds it.
