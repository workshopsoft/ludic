bump: minor
type: feature
**`ludic.roads`: a game can forbid a movement.** `roads_turn_forbid(e_in, e_out)` forbids the move from one edge into the next as
a RoadTurns row would (routes go round it, a car never takes it) until the next `roads_build`: for a movement the rows do not rule
out but the game knows cannot be made, such as a slip road into the far carriageway of a divided motorway whose median barrier runs
on through the merge.
