bump: minor
type: feature
**`ludic.roads`: merges, junctions that do not lock, multi-lane U-turns together.** Two movements that end in one lane and come
together without crossing (a slip road into a highway's kerb lane, a side road turning into the near lane) were one at a time,
each holding the junction for its whole path: a long gore held a highway car at its start for as long as a slip road car was
anywhere in it. Now they go in the order they reach the lane (`merge.ludic`): a car is let in beside the other when it will be
wholly behind it or wholly ahead of it, or when it comes from the higher priority road and the other can still stop short of the
merge zone; it then follows the cars of the other movement nearer the mouth, and a car of the lower priority road gives way short
of the zone to a moving car of the higher one. A car that goes first but has no room beyond the junction no longer holds back the
cars whose paths meet its own (a full dead-end stub locked its junction). The lanes of a several-lane road loop round a dead end's
circle a lane's width and a metre apart, so they go round together. `roads_enter_why(slot)` (`ROADS_ENTER_*`) says why a car may
not go on. Tests: `tests/junctions_test.ludic` (a long gore both ways, the no-room junction).
