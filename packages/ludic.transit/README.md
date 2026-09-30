# ludic.transit

Public transport as data a map paints - modes (bus, tram, metro, train, ferry, taxi), lines with their stops, headways by
the hour and operating hours, stops with stand points and transfer links - and on it: a **timetable that is a pure function
of the clock** (no vehicle is simulated; where any run is at any second is worked out), boarding with capacity and fares
through a wallet port, a **journey planner** (earliest arrival, transfers, walking legs), and a hand-off of the vehicles
near a player to the game's traffic through a port. Uses [`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.transit"
```

Conventions: metres, seconds, hours of the day; **x east and z south** (a map from above, z down the page); time is **game
seconds since day 1 00:00** (`int`; a run past midnight simply has a time past 86 400). Nothing here draws, spawns a body or
reads another mechanic: the people who ride are ints the game names (`rider`), the money is behind `TransitPay`.

## The data

Two game tables (open, filled from `.lres` by the game) and two `@PerMap` tables a designer paints under
`maps/<map>/transit/`. `ludicc --check` reads every map against them, including that a line's stops and mode exist.

```lres
# TransitModes: how a kind of transport runs and is paid for (def TransitModes from "modes.lres")
metro { capacity: 400, speed: 20.0, accel: 1.0, dwell: 25, road: false, fare_kind: "zone", fare_base: 2, fare_per_zone: 1, transfer_free: 600 }
bus   { capacity: 60, speed: 10.0, road: true, detour: 1.3, fare_kind: "flat", fare_base: 2, transfer_free: 600 }
taxi  { capacity: 4, speed: 12.0, on_demand: true, wait: 200, detour: 1.4, fare_kind: "distance", fare_base: 3, fare_per_km: 2 }

# transit/stops.lres
c { name: "Cedar", x: 2000.0, z: 0.0, zone: 1, bays: [{ line: "M", x: 2000.0, z: 6.0 }], links: [{ to: "c2", secs: 40 }] }

# transit/lines.lres
M {
  name: "Metro"
  mode: "metro"
  stops: [{ stop: "a" }, { stop: "b" }, { stop: "c", dwell: 40 }, { stop: "d" }, { stop: "e" }]
  headways: [{ from: 5.0, to: 9.0, every: 300 }, { from: 9.0, to: 17.0, every: 600 }, { from: 17.0, to: 24.0, every: 480 }]
  first: 5.0
  last: 24.0
}
```

- **Mode** (`TransitMode`): `capacity`, `speed` (cruise m/s) and `accel` (a short hop never reaches cruise: the time between two
  stops is `d / v + v / a`, or `2 sqrt(d / a)` when `d < v^2 / a`), `dwell` (seconds standing at a stop), `road` (traffic
  drives it near a player) or its own track, `on_demand` (a taxi: no line, no timetable; `wait` for pickup, `detour` the road
  over the straight line), and the **fare model**: `fare_kind` `flat` (`fare_base`), `distance` (`fare_base` + `fare_per_km` per started
  kilometre of the straight line between the stops), `zone` (`fare_base` + `fare_per_zone` per zone crossed, from each stop's `zone`) or
  `free`; `transfer_free` seconds inside which a next ride of the same mode is free.
- **Settings** (`TransitSetting`, the first row of `def TransitSettings from "transit.lres"`): `walk_speed`, `max_walk` (to a stop and
  from a stop), `walk_only` (a walk all the way is offered up to this), `transfer_radius` (stops this close are a walk apart without a
  link), `min_transfer` (seconds to change vehicle), `horizon` (the planner gives up on a ride leaving later than this), `default_headway`.
- **Stop** (`TransitStop`): position, `zone`, `bays` (the stand point of each line at this stop: a bay, a platform; the stop's own point
  otherwise) and `links` (walks to other stops; `secs` 0 is worked out from the distance). The lines a stop has are the lines that call
  at it, written once, on the line (`transit_stop_routes`).
- **Line** (`TransitLine`): `stops` (each a `TransitCall`: the stop and, optionally, its own `dwell`), `pts` (a **drawn path**: the
  polyline the vehicles follow, stops projected onto it; none: a straight run from stop to stop, lengthened by the mode's `detour` on a
  road), `segs` (road segment names, for the game's traffic to drive: this package never reads roads), `loop` (back to the first stop),
  `both` (also runs the stops in reverse), `headways` (`from` <= hour < `to`, `every` seconds), `first` and `last` (the hours of the
  first and last departure; past 24 is the night service of the next morning) and `offset` (stagger lines that would leave together).

`transit_build(tr, stops, lines)` turns the loaded tables (`transit_stops_load(stops, map)`, `transit_lines_load(lines, map)`) into the
network: a spatial grid of stops, each line's polyline with arc lengths, **routes** (`line * 2` the stops in order, `line * 2 + 1`
the way back) with the seconds to every stop, the timetable, who serves each stop and the walks between stops. It returns false when a
row is wrong (an unknown mode, an unknown stop, fewer than two stops, a taxi on a line) and `transit_error()` says the first; every row
that is right is built.

## The timetable is a function of the clock

A route's departures are a list of seconds past midnight made from its headways (each gap is the headway at the hour of the last
departure). A **run** is named by when it leaves the first stop. Nothing is stored per run and nothing ticks:

| | |
| --- | --- |
| `transit_next_run(tr, route, k, t)` | the run that leaves stop index `k` of a route at or after `t` (its name), or -1; it skips a day `TransitWorld.weekday_ok` refuses (a holiday, a strike) |
| `transit_runs_at(tr, route, t, out)` | the runs on the road at `t` (left the first stop, not yet at the last) |
| `transit_pose(tr, route, run, t)` | where a run is at `t`, into `transit_pose_x/_z` (metres), `_hx/_hz` (the way it faces), `_speed`, `_stop` (the stop index it stands at, or -1) and `_next` |
| `transit_vehicles_near(tr, x, z, r, t, routes, runs)` | every run within `r` of a point |
| `transit_run_arrives/_leaves(tr, route, run, k)`, `transit_route_arrive/_leave/_duration`, `transit_departure(tr, route, j)`, `transit_runs_per_day` | the offsets and the day's list |

The position between two stops is the **constant-speed interpolation** of the arc length between the time it leaves one and arrives at the
next, sampled on the line's polyline (the drawn path, or the stops in order). The same answer on every machine, in any order of asking:
**far from every player no vehicle exists**, which is what makes a city of lines cost nothing.

## The journey planner

`transit_plan(tr, x0, z0, x1, z1, depart) -> legs` (or -1: no way) is a **time-dependent Dijkstra over stops**: the walk from the origin
reaches the stops near it; each stop taken off the heap boards the next run of every route that serves it (the timetable decides when,
after `min_transfer` if it arrived by a ride or a walk) and reaches every stop downstream at that run's own time; a walk links a stop to
its neighbours (links, and stops within `transfer_radius`); the walk to the destination is tried from every stop taken, and the search
ends when nothing left on the heap could beat the best arrival. A route's later stops are not rescanned from a run already boarded
earlier (the round trick of RAPTOR), labels are stamped so a query clears nothing, and the heap and the answer are kept lists: a query
allocates nothing. A walk the whole way (within `walk_only`) competes; ties keep the walk.

The answer is **legs** - walk, wait (for the run), ride (route, run, the two stops), walk - read back with `transit_plan_count/_kind/_from/_to/
_route/_line/_run/_stop0/_stop1/_x0/_z0/_x1/_z1/_leg_fare`, with `transit_plan_arrival`, `transit_plan_fare` (each ride by its mode's model; a
next ride of the same mode inside `transfer_free` is free) and `transit_plan_rides`. `transit_eta(...)` is the seconds from `depart` to
arriving (-1 none), for a caller that wants a number. A taxi is not a line: `transit_taxi_mode()`, `transit_taxi_secs(mode, ...)` (the wait,
then the road) and `transit_taxi_fare(mode, ...)`.

Measured (`tests/transit_test.ludic`, one thread, Apple silicon): about **0.4 us a plan** on the 13-stop test map, **about 70 us a plan** on a
generated 24 x 24 grid of buses (576 stops, 48 lines, a run every 7 minutes, transfers at every crossing). `ludic.citizens` shares plans
through a cache, so what a city costs is the distinct commutes, not the people.

## Boarding, capacity and fares

A run that has riders gets a block of counts (riders aboard on each leg between stops) in a hash table keyed by route and run; a ticket is a
rider's seat from one stop to another.

| | |
| --- | --- |
| `transit_board(tr, rider, route, k0, k1, at, pay)` | a seat on the next run that leaves stop index `k0` at or after `at`, to stop `k1`: a ticket, or -1 - nothing runs, **no room on a leg** (`TRANSIT_F_FULL`), or **the fare was not paid** (`TRANSIT_F_UNPAID`); `pay` false boards without charging (a pass, a fare the plan covered) |
| `transit_leave(tr, ticket, k)` | off at stop index `k`: the seat goes back to the legs no longer ridden |
| `transit_load(tr, route, run, k)`, `transit_capacity`, `transit_load_add(tr, route, run, k0, k1, n)` | riders aboard; a crowd counted in bulk by a game that does not simulate it rider by rider (whole groups, all or none) |
| `transit_ticket_live/_rider/_route/_run`, `transit_riding` | tickets |

Riding is **on schedule**: a ticket ends by itself when its run reaches the rider's stop (`TRANSIT_F_ALIGHTED`), and the counts of runs long
gone are freed. The fare goes through `TransitPay.charge(rider, amount)` (false: the rider cannot pay and is not let on) and
`TransitPay.refund`.

## Vehicles near a player

```text
export port TransitBody {
  near: fn(float, float) -> bool                    # a player is close enough here for a vehicle to be real
  embody: fn(int, int, int, float, float, float, float, float) -> bool   # (slot, line, mode, x, z, hx, hz, speed): the game took it
  place: fn(int, float, float, float, float, float, int) -> void         # (slot, x, z, hx, hz, speed, stopped_at) each tick
  release: fn(int) -> void                          # the vehicle went out of range, or its run ended
}
```

Every quarter of a second (`TR_SCAN`) the system looks at the runs on the road and offers those `near` a player to `embody` (up to 64 at once,
`transit_config_bodies`); the game makes a vehicle (ludic.cars on the road segments the line names, a kinematic model) and from then on is
told **where the schedule has it** every tick (`place`). **The schedule stays the truth: the body follows it or is put on it**, so a
player who follows a bus sees the bus every other machine computes, and doors open at the stops on time. A vehicle out of range for a
second, or whose run ended, is released (`TRANSIT_F_EMBODIED`, `TRANSIT_F_RELEASED`); a game that loses a body itself says `transit_body_lost(slot)`.

## Ports

```text
TransitWorld { now: fn() -> int (game seconds; -1: run on Tick.hours), weekday_ok: fn(int) -> bool (day number) }
TransitPay   { charge: fn(int, int) -> bool, refund: fn(int, int) -> void }
TransitBody  { near, embody, place, release }       # above
```

Every member has a default, so nothing needs binding: the package keeps its own clock (`transit_set_time`), every day runs, every fare is
paid, nobody is near.

## Verbs, facts, save

The verbs are the exported functions above (`transit_build`, `transit_plan`, `transit_eta`, `transit_pose`, `transit_board`, ...). The facts
are `transit_facts(tr) -> Queue<TransitFact>`: `TRANSIT_F_BOARDED`, `_ALIGHTED`, `_FULL`, `_UNPAID`, `_EMBODIED`, `_RELEASED` (`rider`, `line`, `stop`,
`run`, `slot`, `fare`). `transit_system()` is `"transit"` in `PH_SIMULATE`: reset, tick (the clock, the scan, the ticket and count expiry), and
the save section (version 1): the clock and the tickets; the network is the map's, built on load, and the timetable needs nothing saved. Dev
verbs for an editor's link: `transit_plan x0 z0 x1 z1 [depart]` and `transit_stats`.

## Tests

`ludic test packages/ludic.transit`, on `tests/maps/metro` (a metro along an axis with a hub, a bus crossing it, a tram loop on a drawn path, a
stop no line serves) and `tests/maps/broken` (every kind of wrong row): the network and its routes' offsets, the timetable from the headways
and across midnight and a held-back day, poses at any time and in any order, the drawn path, fares of every model, plans with a ride, a change,
a walk, none, and at night past the last run, determinism, boarding with capacity and fares, tickets ending on schedule, vehicles handed to and
taken back from a fake traffic, the save, and the two planner timings above.

## v2

Capacity-aware planning (a full run is skipped); riders counted from `ludic.citizens` into the runs' loads as aggregate demand; fare caps and
passes; a day-of-week pattern per line (today a line runs every day the game allows); a headway that answers demand; real vehicles that dwell
until boarded (a bus held at a stop); turn-by-turn detours when a road closes; walking legs that follow sidewalks through a nav port.
