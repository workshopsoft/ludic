bump: patch
type: fix
**The alloc fence no longer reads declared bytes as a release.** `Mem.kept()` and the frame judge subtracted the declared (`@alloc_ok`) growth from the live count, which never held it, so a frame that made only declared memory reported a negative `kept` (-3360) and `alloc_fence_declared` / `alloc_ok_private` failed. A merge had put back lines that "declared bytes are never judged" had removed; they are removed again and the seeds regenerated.
