bump: patch
type: fix
**`ludic.roads`: the nearest road is found anywhere on a large map.** The grid over the road polylines keyed
a cell by a product of two biased cell numbers that wrapped negative in 32 bits, and an `IntMap` keeps keys of
0 or more only: when its table grew (past 48 cells) every cell with a negative key was dropped, so
`roads_nearest` and `roads_nearest_y` answered with a road's far point (its midpoint on a straight road) for
any point near a road in such a cell, and a car could not be placed on it ("not on a lane"). A cell's key is
now its two numbers cut to 15 bits each and packed into 30, never negative; two cells 1,048 km apart share a key,
which only costs a few more steps scored.
