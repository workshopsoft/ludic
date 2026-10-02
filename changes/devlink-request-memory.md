bump: patch
type: fix
**An editor's live link no longer fails the alloc fence, and a repeated request makes nothing.** A dev or headless
run driven over `ludic.devlink` died with exit 86 the first time a request kept memory once judging had begun - a
`ui_model` (the JSON encoder's buffer, a model list's items), a `shot` (its path), a reload - although none of it is
a player's. A request that grows the heap is now taken as the fence's new floor, as a load is (`Mem.play()` +
`Mem.settled()`, the rule the game's regrow verbs carried by hand), and the rest of that frame is judged as ever; a
request that keeps nothing leaves the fence alone. And so that driving a game (`key "w" "down"`, `look`, `step`,
`ui_model "Hud" "<out>"` again and again) keeps nothing, a string argument is made once per distinct text
(`DL_WORDS`, 256) instead of once per request: 200 repeated requests grew the heap 6400 bytes, now 0.
`tests/devlink_fence_test` holds both: 40 keeping requests over 2000 judged frames fail none, and repeats make nothing.
