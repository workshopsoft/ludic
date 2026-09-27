bump: patch
type: fix
**A dispatched action no longer allocates a record each time.** `dispatch A { ... }` made a fresh
record for the queue, and Ludic frees nothing, so a system dispatching every frame (an input's
`Move`, a frame's time) grew the program by a record a frame. The queue now keeps a list per
action: a dispatch takes the next one (making one only when all are queued), fills every field
as `new` would - given, or its default - and `drain_actions()` hands them all back once the queue
is empty. A reducer reads its action only during the drain, so nothing sees a record after it is
reused; keep what must last in the state, not the action. `ludic.base`'s `actions_test` holds a
reused record getting its defaults back.
