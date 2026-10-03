bump: patch
type: fix
**A dev link session no longer blinds the alloc fence.** A request that grew the process heap was taken as the
fence's new floor (`Mem.play()` + `Mem.settled()`), and the heap moves with every other thread's allocations (Metal,
the driver), so 230 of a driven session's requests in 12000 frames re-floored it - each one resetting every declared
site's rising streak, so "declared but unbounded" could never be said in a session driven over the link. Now only a
request that kept memory the fence counts (`Mem.kept()` rose while it was answered: a model's JSON, a path, a reload)
re-floors; one that kept nothing, or only moved the heap, leaves the fence alone. `tests/devlink_fence_test` adds a
request whose memory is declared: the heap grows and the fence is not settled again for it.
