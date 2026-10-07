bump: patch
type: fix
**A session driven over the dev link keeps nothing, so it no longer fails the alloc fence.** Every `shot` made its
path into a new text that nothing let go, and an editor names every shot afresh (`ludic-studio-shot-<pid>-<n>.ppm`):
since only a request that keeps memory the fence COUNTS re-floors it (`devlink-floor-kept-only`), these declared
texts rose window after window until a QA session failed with exit 86, "declared but unbounded" at `text_of`
(reproduced headless: fresh-path shots every 3 s fail at frame 4200; a reachability scan finds the old paths
unreachable). Now a request's texts are the request's (`made.ludic`): a string argument or an `ui_override` path is
made when its request is read and let go (`free`) when the next one is, and a shot's path when the next shot is
taken. The per-distinct-word cache (`DL_WORDS`, `dl_words`) is gone with it: it was bounded, but an agent asking
about ever new components or keys still rose under the fence. **The contract for a port member or a declared verb:
a string it is handed lives for the request (a shot's path until the next shot) - copy it to keep it**, as
`map_load`'s `keep`, ludic.ui's `ui_override` and `Input.type` already do. `tests/devlink_texts_test`: 296 shots
with fresh paths grew the heap 14208 bytes before and 0 now; 396 requests of a word never sent before 8320 and 0.
