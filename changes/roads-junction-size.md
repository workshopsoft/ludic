bump: minor
type: feature
**`ludic.roads`: junctions with a size.** A node was a point: a car went from one road's lane to the next at the node
(a jump of a lane's width at a turn, of two at a U-turn), waited 1.5 m short of its centre (inside the junction drawn on
the ground, on its crossings) and a junction let one car in at a time. A game can now give each road's ends their
setbacks (`roads_edge_setbacks`: the waiting line, the turn path's mouths, the clear line), and then a car waits before its
line, drives a continuous turn path from mouth to mouth (one cubic; a U-turn loops round a dead end's circle,
`roads_node_uturn`), at its own speed along it, slowing for its bend (`roads_config_turn_accel`); takes its lane by the side
it turns to (`roads_lane_onto`: a slip road merges into the kerb lane); is not let in while the lane beyond has no room (a
junction kept clear); and, with `roads_config_conflict(width)`, goes through together with every car whose path keeps
apart from its own. Lanes can begin where the bake paints them (`roads_edge_lane_base`: half a median, a one way road on
the right of its line), `roads_config_jam(0)` leaves standing cars to the game, a car that waited 25 s goes first, and a
wandering car with no place to go takes a road on instead of arriving. Every default keeps the old behaviour (the 37
tests stand unchanged); `junctions_test.ludic` adds 7, among them ten minutes of 40 cars on a street grid, a dead end and a
highway merge with no two car bodies ever overlapping. The per-node holder lists (`rd_node_car`, `rd_node_id`,
`rd_node_in`) are gone: a car holds the node it was let into (`RoadCar.hold`), and `RoadCar.pin`/`plane` are the road and
lane it is turning off.
