# ludic.crowd

The ambient population of a living city: pedestrians made round the players by the hour and the district, within
budgets, the same people from the same seed on every machine; simplified by distance (full, mid, far); walking where
the game's nav says, waiting at crossings, sitting on benches and using cash machines, in groups of friends; reacting
to what happens as a `@Machine` (calm, alert, flee, panic, cower, fight, call the police); and kept on clients by a
cheap delta. Uses [`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.crowd"
```

The package never draws, spawns a body or words anything. Everything generic is a row the game fills (what a type of
person is, what a day looks like, how a district fills); the game's own words (an item, an animation, a crime)
ride through unchanged. No map is generated: the zones and scenarios are painted by a designer, per map.

Conventions: metres and seconds, hours in `[0, 24)`, x east and z south, `yaw = atan2(dx, dz)` (0 faces +z).

## The data

Game-wide tables (open, append-only registries: `def` them in code or `def PedTypes from "types.lres"`):

| | |
| --- | --- |
| `PedLooks` (`PEDL_*`) | an appearance set: `variants` (how many looks it makes) and the game's `parts`. A ped's look is a number drawn from its uid |
| `PedTypes` (`PEDT_*`) | walk and run speed, radius, `look` (`@Ref`), `schedule` (`@Ref`), wander distances, `fear` and `bravery`, `alert_at` and `flee_at`, `on_panic` (`flee`, `cower`, `fight`, `ignore`), `civic` (the chance it phones the police), `call_s`, `fight_s`, `witness` (its weight as a witness), `jaywalk`, `group_chance` and `group_max`, `carry` (items with a chance and a count), `tags` (the game's own words) |
| `PedSchedules` (`PEDS_*`) | `slots`: `from`/`to` hour (over midnight when `to < from`), `act` (`walk`, `stand`, `sit`, `shop`, `work`, `commute`), `anchor` (a scenario tag to go to), `weight`, `min_s`/`max_s` |
| `CrowdThreats` (`CTHR_*`) | a shot, a blast, a shove: `radius`, `fear`, `falloff`, `needs_sight`, `crime` (the game's crime id, handed back in a report), `max_reports` |
| `CrowdSettings` (`CSET_*`) | the budgets and radii; the first row is used (none: the defaults below) |

Per-map tables (`@PerMap`, painted in an editor, read by `population_zones_load(zones, map)` and
`ped_scenarios_load(scen, map)` from `maps/<map>/crowd/`):

```
# crowd/zones.lres - a polygon of the city and who is in it
downtown {
  pts: [{ x: -300.0, z: -300.0 }, { x: 300.0, z: -300.0 }, { x: 300.0, z: 300.0 }, { x: -300.0, z: 300.0 }]
  density: [{ hour: 0.0, value: 4.0 }, { hour: 8.0, value: 60.0 }, { hour: 18.0, value: 80.0 }]   # peds a hectare
  traffic: [{ hour: 0.0, value: 20.0 }, { hour: 12.0, value: 100.0 }]                              # vehicles a square km
  mix: [{ ped: PEDT_COMMUTER, weight: 3.0 }, { ped: PEDT_SHOPPER, weight: 2.0 }]
  priority: 1                                                                                      # higher wins where zones overlap
}

# crowd/scenarios.lres - where people do something
bench_a { x: 20.0, z: 20.0, yaw: 90.0, tag: "bench", act: "sit", capacity: 2, min_s: 10.0, max_s: 20.0 }
atm     { x: 10.0, z: -30.0, tag: "atm", act: "use", capacity: 1, from: 6.0, to: 22.0 }
smoke   { x: 40.0, z: 40.0, radius: 3.0, tag: "smoke", act: "stand", capacity: 4 }               # an area
```

A curve (`density`, `traffic`) is linear between its points and wraps midnight. A cell-shaped zone is a four-point
polygon. `crowd_build(crowd, zones, scenarios) -> bool` turns the loaded tables into the indexes (a zone cell hash, a
scenario cell hash): false, with `crowd_error()`, for a zone of fewer than three points or a mix naming no type; the
rest is built. It takes everybody alive away first. Editor attributes: `@Ref(PedTypes)`, `@Ref(PedLooks)`,
`@Ref(PedSchedules)`, `@Range`, `@Unit`, `@OneOf`, `@AppendOnly @ByKey` on the registries, `@PerMap @ByKey` on the
map's.

## Who exists: deterministic per cell

The world is cut into square cells (`cell`, 32 m). For the seed and the hour a cell holds a number of **spawn units**
(a person, or a group of friends): the density of the zones over its area (four sample points), over the average
people a unit makes from the mix, the remainder decided by the cell's seed. Unit `k` of cell `(cx, cz)` is a pure
function of `(seed, cx, cz, k)`: where it stands, its type, whether it has friends and how many, each one's look. Its
**uid** packs the cell (11 bits each way), the slot (5) and the member of the group (3): the same on every machine,
and a client can work out a ped's look from it. Nothing random is kept; later choices (the next act, the next
place) are a hash of `(uid, how many choices it has made)`, not a shared dice, so one ped's day does not depend on
another's.

Each pass (`spawn_dt`, 0.1 s) looks at `cells_per_pass` cells of the **ring** round a player (from `spawn_min` to
`spawn_max`, resuming where it stopped, each player's in turn) and makes the units that are missing, at most
`spawn_per_pass` people, never past `max_peds`. A unit is made only where

- `CrowdWorld.active` (the world is simulated there) and `CrowdWorld.spawn_ok` (no player can see it) say yes,
- it is between `spawn_min` and `spawn_max` of a player, and
- the nav's `walkable` says so, or its `snap` finds a sidewalk near.

Another pass takes people away: beyond `despawn` of every player (in sight only past half as far again), over the
budget and beyond `spawn_max` (farthest first, never in sight), and those the hour no longer wants in their cell
(2 a.m. thins a street; never in sight). A unit goes whole, friends with it. A killed ped's place stays empty for
`respawn_s` (`crowd_kill`); a removed one's does not. `crowd_prime(crowd)` fills the ring at once (a load, a teleport).

## LOD tiers and budgets

Every `react_dt` (0.1 s) each ped is tiered by its distance to the nearest player:

| tier | within | steers | avoidance | crossings | drawn as |
| --- | --- | --- | --- | --- | --- |
| `CROWD_FULL` | `full_r` (35 m) | every tick | the people near it | waits for the light | a full character |
| `CROWD_MID` | `mid_r` (85 m) | every `mid_dt` (0.25 s) | none | waits for the light | a character, coarse |
| `CROWD_FAR` | beyond | every `far_dt` (1 s), a step along the way | none | none | an impostor, or nothing |

`max_full` and `max_mid` are budgets on the tiers: when a tier is over its limit its radius is drawn in (5% a pass), when
under, let out again, so the nearest people keep the full tier and the rest fall to the cheaper one; the radii in force
are `crowd_lod_radius(crowd, tier)` and `crowd_lod_count(crowd, tier)` says how many are in each. A game changes
`crowd_budget(crowd, max_peds, max_full, max_mid)` and `crowd_lod_radii(crowd, full_r, mid_r)` for a quality setting.
A ped sitting on a bench stays where it is in any tier, so the bench is never freed by distance alone.

`CrowdBody.place` is told where every ped that stepped now is (and its tier), so the game moves the body, draws the
impostor or does nothing for a far one.

## Ports

`CrowdWorld { players, player_on, player_x, player_z, hour, seed, active, spawn_ok, visible, ground, clear }`,
`CrowdNav { walkable, snap, pick, way, crossing, may_cross }` and `CrowdBody { born, place, gone }`, all defaulted (one
player at the origin, noon, seed 1, simulated and spawnable everywhere, nothing in sight, flat, a clear line, a flat
field where every point is walkable and people walk straight, bodies that go nowhere).

- **Walking is the game's nav.** `way(ped, x, z, gx, gz, out)` writes the next corner of a path into `out` (a list of
  two floats the crowd keeps; false means "straight"); `pick(x, z, rmin, rmax, salt, out)` writes a walkable point
  (sidewalks) for a walk; `snap` the nearest sidewalk point to a spawn; `crossing(x, z)` is 0, 1 for a crosswalk or 2
  for a road, and `may_cross` is the light or the gap in the traffic. Bind them to `ludic.roads` (sidewalks are the
  game's offset of its lanes, crosswalks its junctions; `may_cross` asks the signal phase) or to `ludic.nav` with a
  walker kind (`nav_next_corner` for `way`, `nav_random_near` for `pick`, `nav_nearest` for `snap`). A ped waits at a crosswalk against the light for at most 25 s, and enters a road (2) only when it is a jaywalker (`PedType.jaywalk`, decided by its
  uid) and the traffic allows.
- Every answer is a number or a bool: nothing is allocated asking.

## Schedules and scenarios

A ped chooses its next act from its schedule's slots that cover the hour, by weight. `walk` goes to a point a
`pick` away (`wander_min` to `wander_max`); `commute` is a walk three times as far, a fifth faster; `stand`, `sit`
and `work` stay put for the slot's time. A slot with an **anchor** looks for the nearest scenario with that tag
within 80 m that is open at the hour and has room (`capacity`): it reserves its place (`crowd_scenario_users`),
walks to it (a line of users along a bench, or anywhere in an area), does the scenario's `act` for its time, and
frees it. With none to go to, `sit` and `work` become standing, `shop` a walk. A reserved scenario is freed when its
user runs, panics, is removed or is killed. `CROWD_USING` says who took what and when it was left (the game plays the
scenario's `anim`).

**Groups.** A unit of two to `group_max` walks side by side across the leader's heading and a step behind, at the
leader's pace with a catch-up; it stands when the leader stands; a friend more than 30 m from the leader, or whose
leader was removed, goes on alone. A leader's fear spreads to its friends within 12 m.

## Reactions: a `@Machine`

`CrowdPed.react` (`PedReact`) is moved only by the machine `CrowdSteps`, whose graph is [`steps.lres`](steps.lres):

```
Calm --alarm (fear >= alert_at)--> Alert --settle--> Calm
Alert --report--> Call --called (call_s)--> Alert
Alert --panic (fear >= .85)--> Panic --winded--> Flee --rested--> Alert;  Flee --startled (fear >= .95)--> Panic
Alert --fight (on_panic fight, bravery >= .35)--> Fight --spent (fight_s)--> Alert
Alert --cower--> Cower --steady--> Alert;   Alert --flee--> Flee
```

`crowd_threat(crowd, kind, x, z, source)` raises fear in every ped within the threat's radius: the row's `fear`, by
its falloff, times the type's `fear`, times `1 - 0.6 * bravery`; a threat that `needs_sight` only reaches peds with a
clear line. Fear decays `fear_decay` a second. `crowd_scare(crowd, uid, amount, x, z)` scares one (a bump). Alert
stops and faces the threat; Flee picks the farthest of three `pick`s from it and runs at run speed; Panic runs erratically;
Cower crouches; Fight goes at the source and, within 1.7 m, lands a blow each second (`CROWD_ATTACK`: the game deals
the damage); Call stands on the phone.

**Crimes and wanted.** A threat row with a `crime` (the game's id) is a crime: a witness whose type's `civic` roll
(a hash of its uid and the event) comes up phones the police before it runs, and `CROWD_REPORT` (crime, where, the
`source` the game passed, the witness's weight) is pushed, at most `max_reports` a threat. The package names no
other mechanic: the game's route turns the fact into `wanted_crime(source, crime, x, z)`. The other way, bind
`WantedWorld.witnessed` to `crowd_witnessed(crowd, x, z)`: the weights (`PedType.witness`: a dog 0.2, a cop 2) of the
peds within `witness_r` with a clear line (up to 12, not those cowering, not the far tier) reach `witness_need`.
`crowd_witness_weight` gives the sum.

## Embodying a persistent identity (`ludic.citizens`)

The crowd can give a body to an identity another mechanic owns (a citizen with a home, a job and needs), near the
players, and hand it back. It knows an identity only as an int the owner chooses (`ext`); the filler round it keeps
the density (an embodied ped counts against `max_peds`, so the ring thins to make room).

1. **Embody.** `crowd_embody(ext, type, look, x, z, yaw, has_dest, dest_x, dest_z, act, key, act_left) -> uid` makes
   the body and returns its uid (bit 30 set), or 0 when `ext` already has one or the type is unknown. `look` is a
   seed in the look set's range, or -1 to derive it; `has_dest` with a destination is the current leg; `act` is
   `CROWD_WALK`, `STAND`, `SIT`, ... and `key` the owner's activity key (played by the graph); `act_left` the seconds
   of a standing act. Facts: `CROWD_EMBODIED` (uid, `from` = ext) and `CROWD_SPAWNED`. The owner embodies when the
   identity comes inside its own near radius (within the crowd's full and mid radii) and keeps the uid.
2. **While embodied the crowd owns the position.** The owner does not move it; it reads `crowd_x/_z(uid)`. The ped
   walks the leg and is never scheduled, spawned away or culled by the crowd. At the destination the crowd pushes
   `CROWD_ARRIVED` (`from` = ext) and the ped stands; the owner answers with `crowd_set_leg(ext, has_dest, dx, dz,
   act, key, act_left)`. It reacts to threats like any ped (`crowd_react`, `CROWD_REACTED`, a report to the police).
3. **Hand back.** `crowd_release(ext) -> bool` fills `crowd_handoff()` (valid until the next release): `x`, `z`,
   `yaw`, `dest_x`, `dest_z`, `has_dest` (it had not arrived), `arrived`, `act`, `key`, `act_left` (seconds of the
   standing act still to go), `react`, `fear`; removes the body; and pushes `CROWD_HANDBACK` (`from` = ext, why
   `CROWD_WHY_RELEASED`). The owner writes the record into the identity and simulates it abstractly again. The owner
   releases when the identity leaves its near radius. If the crowd loses the body itself (`crowd_kill`, a reset) it
   pushes `CROWD_HANDBACK` with that why and the place, and the owner reads the identity's fate from it.
4. `crowd_uid_of(ext)` (0 none) and `crowd_ext_of(uid)` (-1 anonymous) translate.

## Animation: parameters and keys, no poses

The crowd writes no pose and plays no animation of its own. Bodies play clips through `ludic.anim` graphs (data,
`AnimSets`); the crowd hands the graph only:

- **parameters**: `crowd_anim_speed(uid)` (ground speed), `crowd_anim_turn(uid)` (yaw rate), `crowd_anim_state(uid)`
  (the reaction: calm, alert, flee, panic, cower, fight, call) and `crowd_act(uid)` (walk, stand, sit, use, wait,
  phone ...);
- **keys, as data**: `PedType.anim_set` (the `AnimSets` row that plays the type), `PedSlot.anim` and `PedScenario.anim`
  (a state key of that graph for a schedule slot or a scenario) - the graph owns the clips, so the clips' own
  `@Clip` bindings live in its rows; an embodied identity's `key` is the owner's;
- **facts**: `CROWD_ACT` (uid, act, `key`) when a near ped begins an act and `CROWD_USING` for scenarios, so the game's
  graph is told once, not every frame.

The far tier is drawn as impostors baked offline from those clips (or not drawn); nothing here samples a clip.

## Traffic

`crowd_traffic_target(crowd)` is the ambient vehicles the zones round the players ask for now (each zone's `traffic`
per square kilometre at the hour, over the discs of `spawn_max` round each player, each cell once), refreshed each
second. Pass it to `roads_traffic_target(n)`; `crowd_traffic_at(x, z, hour)` and `crowd_density_at` answer for a
point (a map preview, a heat map).

## Multiplayer: the host owns the population

One machine runs the crowd (`CROWD_HOST`); a client sets `crowd_role(crowd, CROWD_CLIENT)` and only holds **puppets**:
the people the host said, moved smoothly between messages (`crowd_tick` does it), drawn through the same
`CrowdBody`. Nobody else decides who exists, reacts, or reports (a client's `crowd_threat` does nothing to puppets:
the game sends the threat to the host).

The host, every 50-100 ms (a timer, not a frame), for each client:

```
n = crowd_sync_out(crowd, since[client], x, z, buf)        # peds within sync_r of that client's player, changed since
g = crowd_sync_gone(crowd, since[client], gone)            # uids removed since
... send buf[0 .. 4n) and gone[0 .. g) ...
since[client] = mark                                       # mark = crowd_sync_mark(crowd), once a round for all clients
```

and the client calls `crowd_sync_in(crowd, buf, n)` and `crowd_sync_in_gone(crowd, gone, g)`. A ped is four words: its
uid, x and z in 1/16 m, and a packed word (yaw 8 bits, reaction 3, act 4, tier 2, type 13). The look, the carry and the
name of what it is are worked out from the uid and the game's own tables, so they are never sent. A ped is written when
something wrote it: a FULL ped every tick, a MID ped four times a second, a FAR ped once a second (and any whose act or
reaction changed), so a message to a client is the people that moved near it, not the city: the benchmark's 100 ms
delta is about 90 peds, 1.4 KB, 14 KB/s before compression. A client lets go of a puppet the host stopped mentioning
for 4 s (out of range); a client that missed messages is resent what it lacks by asking with a smaller `since`
(`-1` is everybody). The removed log keeps the last 4096 removals.

## Zero allocation

A ped is a record in a pool (`crowd_reserve(crowd, n)` makes `n` before play) and a row of a `Table` with a grid; a
removed ped's record goes back to the pool, its reaction brought back to Calm by the machine's own `CrowdRecycle`
action. Every query (neighbours, a threat's reach, witnesses, the ring) writes into lists the crowd keeps, the nav
answers through a kept `out`, the facts ride the `Queue`'s ring. The test holds it: a minute of a walking player with
shots fired, spawning and culling the whole time, and the heap does not grow by a byte.

## Verbs, facts, save

| | |
| --- | --- |
| `crowd_build`, `crowd_error`, `crowd_reset`, `crowd_reserve`, `crowd_prime` | set up |
| `crowd_tick`, `crowd_system()`, `crowd_save`, `crowd_load`, `crowd_new()` | the system (`PH_SIMULATE`), its save, a second crowd for a tool |
| `crowd_budget`, `crowd_lod_radii`, `crowd_config` | quality settings |
| `crowd_count`, `crowd_ped_at(i)`, `crowd_alive`, `crowd_x/_z/_yaw/_speed/_type/_look/_act/_lod/_fear/_react/_group_size(uid)`, `crowd_nearest`, `crowd_count_within` | what the game reads |
| `crowd_carry_count/_item/carries(uid, i)` | what a ped carries, from its uid |
| `crowd_threat`, `crowd_scare`, `crowd_witness_weight`, `crowd_witnessed` | what happens, who saw |
| `crowd_embody`, `crowd_set_leg`, `crowd_release`, `crowd_handoff`, `crowd_uid_of`, `crowd_ext_of` | persistent identities |
| `crowd_anim_speed/_turn/_state/_key/_set(uid)` | the graph's parameters and keys |
| `crowd_remove`, `crowd_kill`, `crowd_place`, `crowd_goto` | the game's hand on a ped |
| `crowd_zone_at`, `crowd_density_at`, `crowd_traffic_at`, `crowd_traffic_target`, `crowd_cell_units`, `crowd_cell_seed`, `crowd_unit_id`, `crowd_uid` | the data's answers |
| `crowd_scenario_count/_key/_users` | scenarios |
| `crowd_role`, `crowd_sync_mark/_out/_gone`, `crowd_sync_in/_in_gone` | multiplayer |

`crowd_facts()` is a `Queue<CrowdFact>`: `CROWD_SPAWNED`, `CROWD_GONE` (why: far, culled, removed, killed, reset, sync),
`CROWD_REACTED` (from, to), `CROWD_REPORT`, `CROWD_USING` (scenario, count 1 or 0), `CROWD_ATTACK`, `CROWD_THREAT` (how
many it reached), `CROWD_ACT`, `CROWD_EMBODIED`, `CROWD_HANDBACK`, `CROWD_ARRIVED`.

Save: section `crowd`, version 1: the clock and the places still empty after a kill. The people are the seed's and are
made again round the players.

## Performance

The benchmark (`tests/crowd_bench_test.ludic`, four players walking through a dense city, a dense metro zone at
120 peds a hectare, pure logic: the ports are counters), on an M4 Pro, one thread:

| | |
| --- | --- |
| 2 394 peds (154 full, 719 mid, 1 521 far), a tick | about 25 us on average, 230 us at the worst (the tick a spawn pass falls in) |
| 1 498 peds all FULL / all MID / all FAR, a tick | 94 us / 10 us / 8 us |
| 100 ms delta to one client | about 90 peds, 1.4 KB, 11 us to write |
| the heap over 600 warm ticks | 0 bytes |

The tests' limits (6 ms a tick) are loose, for a busy machine.

## Tests

`ludic test packages/ludic.crowd`: the zones (priority, curves, midnight, broken and empty maps), the ring and the
budgets, the same seed the same people however the players came, the hour thinning, people left behind, two
players, the tiers and their budgets, a walk, a box the nav refuses, a crosswalk's wait, scenarios within capacity,
groups, gunshots and their reports, shoves by type, a blast and the calm after, a fighter, kills and removals, carry,
witnesses, traffic, the facts' balance, a client's copy, the save, and no heap growth; and the benchmark.

## v2

Lane-following crowd flow for the far tier (flow fields over the sidewalk graph, so far peds queue at a light
instead of passing it); a ped using a vehicle (hailing a taxi, a bus stop as a scenario that spawns riders); interiors
(shopkeepers, peds entering a door and leaving the simulation); a fear that spreads from ped to ped beyond groups
(a stampede); witnesses of the wanted kind that follow the player; impostor atlas variants from the look seed
(`ludic.avatar` parts); per-district schedules (a rule that changes a type's schedule by zone); the mid tier delegating its steering to `ludic.nav`'s Detour crowd; time-sliced spawn
passes across frames for a hundred-thousand-ped city; projecting a zone's density onto the road network instead of
the plane.

## Signals

The facts and values an animation graph (or a sound bank) can listen to, by name and without glue, are declared in `signals.ludic` as `SignalSources` (`ludic.base`). A game writes `AnimBindings` rows naming them (`ludic.anim`). They read the fact queue without draining it. The actor is the ped's uid.

| Source | Kind, range | Says |
| --- | --- | --- |
| `crowd.ACT` | fact | a near ped began an act (word: the act's anim state key, value: the act's number): bind it as a request by name |
| `crowd.REACTED` | fact | a ped's reaction changed (value: the new `PedReact`) |
| `crowd.ATTACK` | fact | a ped that fights landed a blow |
| `crowd.speed` | value, m/s | ground speed |
| `crowd.turn` | value, rad/s | yaw rate |
| `crowd.state` | value, n | the reaction as `PedReact`'s number (calm 0 to call 6) |
| `crowd.variant` | value, 0..1 | a value fixed per ped, from its uid, look seed and the world seed (`crowd_anim_variant`): the same every frame and on every machine, spread evenly over the crowd. Feed it to a parameter and give a graph's standing idles `need` bands over it (`0..0.33`, `0.33..0.66`, `0.66..1`) so a crowd standing still does not stand alike |
| `crowd.act_key` | text | the anim state key of the ped's current act: bind it as a request by name |
