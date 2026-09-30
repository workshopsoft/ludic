# ludic.roads

A road network as data a map paints - nodes, roads as splines with lanes and a speed limit, turn rules - and on
it: shortest and fastest routes, and traffic that follows the lanes with spacing and takes turns at junctions.
Cars move through ports (a body the game places, what its physics has in the way). Uses
[`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.roads"
```

The package draws nothing and owns no physics. Each tick it tells the game where every car is
(`RoadsBody.place`) and asks whether the game's world has something in a car's way (`RoadsBody.probe`).

Conventions: metres, **x east and z south** (a map from above, z down the page); the right of a heading `h` is
`(-h.z, h.x)`; `yaw = atan2(h.x, h.z)`, 0 faces +z. `roads_config_drive_left(true)` mirrors the lanes.

## The data: per map, in `maps/<map>/roads/`

Three `@PerMap` tables, so an editor paints roads as splines and the map's own files hold them. The compiler
writes their states (`RoadNodes`, `RoadSegs`, `RoadTurns`) and verbs (`road_nodes_load(nodes, map)` ...).

```
# roads/nodes.lres
c { x: 0.0, z: 0.0, control: "signal", cycle: 6.0 }     # a signal: 6 s a phase
w { x: -100.0, z: 0.0 }

# roads/segs.lres
wc  { from: "w", to: "c", speed: 10.0, priority: 1, phase: 1 }
arc { from: "e", to: "s", speed: 30.0, lanes_fwd: 2, lanes_back: 2, pts: [{ x: 160.0, z: 40.0 }, { x: 60.0, z: 170.0 }] }

# roads/turns.lres
no_ne { node: "c", from: "nc", to: "ce", rule: "forbid" }
```

- **Node**: `x`, `z`, `control` (`free`: by priority, then who came first; `signal`: roads take turns),
  `cycle` seconds a phase.
- **Road** (`RoadSeg`): `from`, `to` (`@Ref(RoadNodes)`), `pts` (control points between), `lanes_fwd`
  (from -> to) and `lanes_back` (0 is one way), `lane_width`, `speed` (the limit, m/s), `priority` (higher
  goes first at a free junction), `phase` (the signal phase that lets it through), `kind`. Its shape is a
  uniform **Catmull-Rom spline** through the node, each point, the other node (the ends run straight in and
  out), sampled at 8 steps a span and measured; an editor reproduces it with `P(t) = 0.5 * (2 P1 + (P2 - P0) t
  + (2 P0 - 5 P1 + 4 P2 - P3) t^2 + (3 P1 - P0 - 3 P2 + P3) t^3)`.
- **Turn** (`RoadTurn`): at `node`, coming in along `from` and leaving along `to`: `free`, `yield`, `stop` or
  `forbid` (routes avoid it too).
- **Car kinds**, a game table `RoadCarKinds` (open, `RCK_*`): `length`, `max_speed`, `accel`, `brake`, `headway`,
  `gap`, `pace` (the share of the limit it drives at), `weight` (its odds when traffic is made).

`ludicc --check` reads every map's three files against these records, including that a road's nodes exist.
`roads_build(roads, nodes, segs, turns)` turns the loaded tables into the graph; it returns false, and
`roads_error()` says the first fault (a turn whose roads do not meet at its node), building the rest.

## The graph

An **edge** is a directed road: `2 * segment` goes from -> to, `2 * segment + 1` back; one without lanes
(`roads_edge_ok`) is not there. `roads_edge_from/_to/_lanes/_length/_speed/_seg`, `roads_node_*`,
`roads_seg_find`, `roads_turn_rule(in, out)`, `roads_pose(edge, s, lane)` into `roads_pose_x/_z/_yaw`
(lanes lie on the right of travel, a one way road is centred), `roads_nearest(x, z)` (a road, `roads_near_s`,
`roads_near_d`) and `roads_edge_for(seg, x, z)` (the edge on the side of the road a point is on).

## Routes

`roads_route_edges(e0, e1, mode, out) -> n` and `roads_route(x0, z0, x1, z1, mode, out) -> n` (each end snapped to
its nearest road, every direction tried): Dijkstra over **edges**, so a turn rule is a wall or a cost and a
U-turn is allowed only where a road ends. `ROADS_SHORTEST` is metres; `ROADS_FASTEST` is seconds (length over
the limit, plus 4 s for a stop, 1.5 s for a yield, a quarter of a signal's cycle). `roads_route_cost()` has the
cost. The heap, distances and parents are kept lists: a route allocates nothing. A route's goal is an edge;
a car drives it to its end.

## Traffic

`roads_spawn(edge, s, lane, kind, dest, wander) -> id` (or -1: no such edge or kind, no room, no way to `dest`),
`roads_spawn_random()`, `roads_despawn(id)`, `roads_traffic_target(n)` (ambient cars kept at n, one made each
0.4 s, only where `RoadsWorld.active` and `spawn_ok` say yes), `roads_car_count`, `roads_car_x/_z/_yaw/_speed/
_edge/_s(id)`, `roads_cars_reserve(n)` (make the pool before play).

Each tick, for each car, the **Intelligent Driver Model**: its acceleration from the speed it wants (the limit
times its `pace`) and what is ahead - the car in front in its lane (on its road, or the one it turns onto), a
junction it may not enter (a wall at the stop line), what `RoadsBody.probe` reports. **Junctions**: a node where
three or more roads end, or any signal, admits one car at a time. The car at the front of its lane that the
rules allow (the signal's green, a stop done - standing a full second - and, for a yield, no higher road within
30 m) and whose road has the higher priority, then whoever waited longest, then the lower id, takes the node
and holds it until it is a car's length into the next road. A car first in line that is made ahead of the holder
takes over the node. A car that stands 90 s is taken off (`ROADS_JAMMED`).

Ports: `RoadsWorld { ground(x, z), active(x, z), spawn_ok(x, z), seed() }` and `RoadsBody { place(id, kind, x, y,
z, yaw, speed), probe(id, x, z, yaw, look) -> distance or negative }`, all defaulted (flat, everywhere,
nowhere-to-place, nothing in the way). Facts: `roads_facts()` - `ROADS_SPAWNED`, `ROADS_ARRIVED`, `ROADS_GONE`
(why: arrived, despawned, jam, map rebuilt), `ROADS_JAMMED`.

## Save

Section `roads`, version 1: the clock, the target, the id counter and the dice. The graph is the map's, built
on load; ambient traffic is made again to the target.

## Tests

`ludic test packages/ludic.roads`, on the maps under `tests/maps` (a crossroads with a fast bypass and a one way
road, a signalled crossing, a one way ring, a map with a turn that does not fit).

## v2

A spatial index for `roads_nearest`; several cars through a junction at once when their paths do not cross
(platoons); lane changes and overtaking; curvature-limited speed; per-lane turn restrictions; pedestrians
crossing (a port); parked cars; routing with avoided roads (a wanted level closing a bridge).
