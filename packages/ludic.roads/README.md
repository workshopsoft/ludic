# ludic.roads

A road network as data a map paints - nodes, roads as splines with lanes and a speed limit, turn rules - and on
it: shortest and fastest routes, and traffic that follows the lanes with spacing and takes turns at junctions.
Cars move through ports (a body the game places, what its physics has in the way). Uses
[`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.roads"
```

The package draws nothing and owns no physics. (Roads are not drawn by `ludic.render3d` or `ludic.city` either: a grep of both
finds no road mesh, curb or sidewalk code, only the words "road" in a comment and in `CityBlock.source`, so there was
nothing to move. The surfaces are baked offline, see [The bake](#the-bake).) Each tick it tells the game where every car is
(`RoadsBody.place`) and asks whether the game's world has something in a car's way (`RoadsBody.probe`).

Conventions: metres, **x east and z south** (a map from above, z down the page); the right of a heading `h` is
`(-h.z, h.x)`; `yaw = atan2(h.x, h.z)`, 0 faces +z. `roads_config_drive_left(true)` mirrors the lanes.

## The data: per map, in `maps/<map>/roads/`

Three `@PerMap` tables, so an editor paints roads as curves and the map's own files hold them, and more for streets
that are more than a line (profiles, furniture rules, props, the bake: below). The compiler writes their states
(`RoadNodes`, `RoadSegs`, `RoadTurns`, `RoadProfiles` ...) and verbs (`road_nodes_load(nodes, map)` ...). A file a map
does not have is an empty table; every field added after the first version has a default, so an older map reads as it
always did.

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
  `cycle` seconds a phase, `kind` and `radius` (below).
- **Road** (`RoadSeg`): `from`, `to` (`@Ref(RoadNodes)`), `pts` (control points between), `handles`, `lanes_fwd`
  (from -> to) and `lanes_back` (0 is one way), `lane_width`, `speed` (the limit, m/s), `priority` (higher
  goes first at a free junction), `phase` (the signal phase that lets it through), `kind` (`street`, `highway`,
  `track`, `lane`, `alley`, `pedestrian`, `stairs`), `profile` (a `RoadProfiles` key, `""` for none), `taper`, `name`,
  `level` and `heights` (below). Its shape is the curve below.
- **Turn** (`RoadTurn`): at `node`, coming in along `from` and leaving along `to`: `free`, `yield`, `stop` or
  `forbid` (routes avoid it too).
- **Car kinds**, a game table `RoadCarKinds` (open, `RCK_*`): `length`, `max_speed`, `accel`, `brake`, `headway`,
  `gap`, `pace` (the share of the limit it drives at), `weight` (its odds when traffic is made).

A map holds at most **16,384 roads** (`RD_MAX_SEGS`); a turn is keyed `in * 32768 + out` over the edge numbers
(`RD_TURN_KEY`).

### Heights, levels and structures

`ludic.roads` drives on a plan; a map with flyovers, bridges and tunnels tells its roads apart by height:

- `RoadSeg.heights`: the **design height** of each anchor, listed as `handles` are (row `k` is anchor `k`: 0 the `from`
  node, then each of `pts`, last the `to` node), each `{ y: 12.5 }` (metres, y up, sea level 0) or `{ free: true }`
  for an anchor with none. Empty is no design: the road follows the ground, which is how every map worked before.
  A list that does not have a row for every anchor is a fault (`roads_build` says it and builds the road with no
  design). Between two anchors that have a height the road runs straight from one to the other, and beyond the
  first and last it stays at theirs. Ludic Studio grades the roads that have none on the terrain, up to the
  profile's `max_grade`, and keeps these heights exactly.
- `RoadSeg.level`: `ground`, `structure` (a bridge, viaduct or flyover deck) or `tunnel`. `roads_seg_level` reads it.
- `roads_seg_designed(seg)`, `roads_seg_height(seg, s)` (the design height `s` metres along, or the game's ground under
  it where there is none), `roads_pose_y()` after a `roads_pose` (a car's height: the cars are placed at it).
- `RoadStructures` (`roads/structures.lres`, keyed): a stretch of one road that is a bridge, viaduct, flyover or tunnel:
  `seg` (`@Ref(RoadSegs)`), `from` and `to` (metres along it, `to` 0: to its end), `kind` (`bridge`, `viaduct`,
  `flyover`, `tunnel`), `type` (`beam`, `arch`, `cable`, `box`), `over` (what it crosses: `water`, `road`, `rail`,
  `valley` ... the game's word), `deck_w` (0: the road's own width), `deck_t`, `parapet`, `pier_spacing` (0: none) and
  `gaps` (`{ from, to }` ranges in metres from `from` that keep clear of piers). Driving ignores it; the studio
  bakes the structure from it.
- `RoadProfile` also has `median` (a strip down the middle: half of it is added to each side), `shoulder` (added to
  each side beside the outer lane) and `max_grade` (rise over run, default 0.08; stairs are exempt).

`ludicc --check` reads every map's files against these records, including that a road's nodes and profile exist.
`roads_build(roads, nodes, segs, turns)` turns the loaded tables into the graph; it returns false, and
`roads_error()` says the first fault (a turn whose roads do not meet at its node), building the rest.

### The curve

The anchors of a road are `A_0` = the `from` node, `A_1 ..` = `pts`, `A_last` = the `to` node.

- **No `handles`** (the list is empty): a uniform **Catmull-Rom spline** through the anchors (the ends run straight in
  and out), sampled at 8 steps a span and measured, exactly as before; an editor reproduces it with
  `P(t) = 0.5 * (2 P1 + (P2 - P0) t + (2 P0 - 5 P1 + 4 P2 - P3) t^2 + (3 P1 - P0 - 3 P2 + P3) t^3)`.
- **With `handles`**: a chain of cubic **Beziers** through the same anchors. Span `i` runs `A_i -> A_(i+1)` with
  controls `C1 = A_i + out_i` and `C2 = A_(i+1) + in_(i+1)`, and
  `B(t) = (1-t)^3 A_i + 3 (1-t)^2 t C1 + 3 (1-t) t^2 C2 + t^3 A_(i+1)`. Handle row `k` (`RoadHandle { ix, iz, ox, oz,
  smooth }`, offsets in metres from the anchor; row 0 is the `from` node, rows past the list's end are all zero)
  gives `in_k = (ix, iz)` and `out_k = (ox, oz)`. A side that is exactly `(0, 0)` is **automatic**: with the
  tangent `T_k = (A_(k+1) - A_(k-1)) / 2`, `out_k = T_k / 3` and `in_k = -T_k / 3`. The missing neighbour of an end
  anchor is the anchor itself (`A_(-1) = A_0`, `A_(last+1) = A_last`, what the spline does), so **an all-automatic
  chain is the Catmull-Rom spline** and a road can be given handles one anchor at a time. Each span is sampled at
  `n = clamp(ceil(control polygon length / 4 m), 8, 64)` steps and the polyline measured. `smooth` is the editor's
  (it keeps the two sides of a handle in line); the curve reads the four numbers. A zero-length or degenerate span
  is sampled as the point it is: its road has no length, so no lanes.

Everything that reads a road's shape (`roads_pose`, `roads_nearest`, lengths, routes, traffic) reads the one sampled
polyline, so the same curve is driven as is drawn. `taper` (0.2 to 4) is the width multiplier at the `to` end (1 at
`from`): the baked surface widens or narrows linearly by distance along the road; driving ignores it.

### Node kinds

`kind`: `junction` (the default), `roundabout`, `plaza` or `deadend`; `radius` (metres, 0: the kind's own default) is the
plaza's disc or the roundabout's ring. Driving treats a plaza like a free junction, a dead end like a node with one
road, and a roundabout like any node: the studio models it as a real one way ring of roads around the node, so the graph
needs nothing special. The studio draws and bakes the kinds.

### Profiles: a street's cross-section

`RoadProfiles` (`roads/profiles.lres`, keyed) holds cross-sections as data. The first fields (`lanes_fwd`,
`lanes_back`, `lane_width`, `speed`, `priority`, `kind`) are what a studio applies to a road when it picks the
profile; the rest is the section, in metres, left and right seen along the heading from -> to:

```
 walk_l plant_l park_l  curb  gutter   carriageway   gutter  curb park_r plant_r walk_r
|------|-------|------|||-----|=============[ tram ]=============|-----|||------|-------|------|
  mat_walk  mat_plant  mat_park   mat_curb        mat_road (tram bed: mat_tram, tram_w, centred)
```

`carriage` overrides the carriageway width (0: lanes times `lane_width`, which is how a pedestrian way or a flight of
stairs, with no lanes, gets a width); `curb_h` / `curb_w` (0.15 each), `gutter` (0.3); `walk_*`, `plant_*` (the
planting strip between curb and sidewalk), `park_*` (a parking lane beside the carriageway); `tram` with `tram_w`;
`steps` is a riser height in metres (0: not stairs), stairs are built as steps between the road's two ends; `mat_road`,
`mat_curb`, `mat_walk`, `mat_plant`, `mat_park`, `mat_tram` are material slot names the game maps to materials.
`RoadSeg.profile` is a `@Ref(RoadProfiles)`: `ludicc --check` fails a road whose profile is not in the map's file, so
a map that uses profiles ships the file; a road with no profile (`""`) needs none. The starter
[`data/profiles.lres`](data/profiles.lres) has `boulevard`, `tram_avenue`, `avenue`, `street`, `lane`, `alley`,
`pedestrian`, `stairs` and `highway`: copy it into `maps/<map>/roads/` and edit.

### Furniture rules and props

`RoadFurnitureRules` (`roads/furniture.lres`, keyed) says where street furniture goes: `kind` (`street_lamp`, `bench`,
`bin`, `bollard`, `tree`, `bus_stop`, `kiosk`, `traffic_light`, `stop_line`, `sign_stop`, `sign_yield`, `sign_name`
...), `model` (a kit asset key), `profiles` (space separated profile keys, or `*`), `side` (`both`, `left`, `right`,
`alternate`), `zone` (`walk`, `plant`, `park`, `curb`, `road`: the strip of the section), `offset` (metres from the
zone's curb side towards the far side), `spacing` (metres along the street, 0: one at the place), `start` / `stop`
(margins from the road's ends), `junction_gap`, `yaw` (`to_road`, `from_road`, `along`), `scale`, `min_length` (the
shortest street it applies to) and `at`: `street` (along it) or a place, a `junction`, a `signal` node, a `stop` or
`yield` turn, a `deadend`, or a junction of a `named` street. The starter
[`data/furniture_rules.lres`](data/furniture_rules.lres) has lamps every 28 m, benches, bins, bollards on pedestrian
streets, trees, bus stops, traffic lights, stop lines and the signs.

The studio runs the rules **once** and writes what they made into `RoadProps` (a `@PerMap @Chunked(256)` table,
`roads/props/{cx}_{cz}.lres`, like the city's buildings): `key`, `kind`, `model`, `x`, `z`, `yaw` (degrees, 0 faces
+z), `scale`, `edge` (`@Ref(RoadSegs)`) and `s` (metres along it), `node` (`@Ref(RoadNodes)`), `text` (a name sign's
text), `rule` (the rule it came from). A designer can also place a prop by hand. The game loads the props and places
their models; nothing is generated at run time.

### The bake

`ludic.roads` still draws nothing. The road surfaces, curbs and sidewalks are baked **offline** by Ludic Studio (its
`roads_bake` tool) into one glTF per map, `maps/<map>/roads/roads.glb`, with one mesh node per material slot (`mat_road`,
`mat_curb` ... the names are the glTF material names), and a row in `RoadBakes` (`roads/bake.lres`, keyed) with the
`asset` (the glTF path), the studio's `hash` of the data it was built from (so a bake older than the roads is known)
and `tris`. The game loads the glTF and maps the slot names to its materials.

## The graph

An **edge** is a directed road: `2 * segment` goes from -> to, `2 * segment + 1` back; one without lanes
(`roads_edge_ok`) is not there. `roads_edge_from/_to/_lanes/_length/_speed/_seg`, `roads_node_*`,
`roads_seg_find`, `roads_turn_rule(in, out)`, `roads_pose(edge, s, lane)` into `roads_pose_x/_z/_yaw`
(lanes lie on the right of travel, a one way road is centred), `roads_nearest(x, z)` (a road, `roads_near_s`,
`roads_near_d`) and `roads_edge_for(seg, x, z)` (the edge on the side of the road a point is on). `roads_nearest` looks at the plan only, through
a grid of 32 m cells over the polylines (it answers in a few cells, so it may be asked every frame; a point far off the map costs at most a search of the grid's whole box, however far it is, and a NaN or infinite one has no road, -1); `roads_nearest_y(x, y,
z)` also counts how far y is from the road's height there (its design height, else the game's ground), so under a flyover it
is the road below and on it the road above: the road's height at the hit is `roads_near_y`, the plan distance `roads_near_d`.

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
road, a signalled crossing, a one way ring, a map with a turn that does not fit, and `curved`: handles, the same road
with and without automatic handles, a plaza, a dead end, a roundabout ring, a zero-length road, and the starter
profiles and furniture rules), `flyover` (a ground road under a deck, a ramp and a road with one height; its structures
and a profile with median, shoulder and max grade), `badheights`, and a 16,384 road map the test writes, builds and removes.

## v2

Several cars through a junction at once when their paths do not cross
(platoons); lane changes and overtaking; curvature-limited speed; per-lane turn restrictions; pedestrians
crossing (a port); parked cars; routing with avoided roads (a wanted level closing a bridge).
