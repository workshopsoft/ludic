bump: patch
type: fix
**A screen opened for the first time in play no longer fails the alloc fence.** ludic.ui's pools grow to the most a
screen has needed and stay, and their nodes, scopes and passes were declared (`@alloc_ok`), but the Values they hold
were not: the first opening of the pack in a judged run ended it (`value_lists` / `value_add` from `uv_new` /
`ev_call_with`, exit 86), and so did the first map opening (`value_new` from `uv_float`). The Value a pool or the call
ring grows by is now made by `ui_kept_val` (declared); the runtime's Value containers declare their room
(`value_lists`, `value_add`, `value_put`), a kept list's items past its most (`value_item_new`) and the JSON encoder's
one buffer (`jo_room`) - each a high-water mark, still judged as "declared but unbounded" if it keeps rising. And a real
leak under it: a pooled Value a call answered a list into (`value_into_ints`) lost its items whenever the pool handed
it out as something else, so every opening of a screen made them again - eight Values, for good. A list now marks
the items `value_item` made as its own (`VL_OWNS`), keeps them as spares when it is turned to another kind or cut
(`value_become`, `value_into_list`), and a list of another's Values (`value_add`) is emptied, never turned.
`ludic.ui/tests/ui_value_reuse_test` turns an eight-item answer away and back 500 times: the heap grows 0. A run that opens and closes the pack, craft, map, journal, pause and settings 100 times
under `R3D_ALLOC_FENCE=fail` keeps nothing.
