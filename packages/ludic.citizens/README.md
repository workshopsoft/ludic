# ludic.citizens

A persistent life simulation for a large population: the people of a city, each with a home, a job, needs, money, friends and a
day. They get up, go to work by the way they prefer (on foot, by public transport, their own car, a taxi, or a mix), do their
jobs, come home, eat, wash, shop, go out, visit a friend, sleep - chosen by what they need, what it costs, what the hour allows
and what they are like - and what they earn and spend feeds back into what they can choose. **Far from every player a citizen is an
event, not a body** (an activity at a place until a time, or a trip until a time), so hundreds of thousands cost a few microseconds
a minute; near a player they walk real paths, and nearer still are handed to the game's crowd, cars and NPCs and handed back.
Uses [`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.citizens"
```

Everything generic is data a game fills; nothing names a game's places, words or animations. The buildings come from the city through a port
([`ludic.city`](../ludic.city/README.md)), the transport from another ([`ludic.transit`](../ludic.transit/README.md)), the bodies go to a third
([`ludic.crowd`](../ludic.crowd/README.md), cars, an NPC package). No pose is written here or anywhere it touches: what a body should play is
a **graph state key and a clip key in the `Activities` rows** (from the artist's clips, played by `ludic.anim`).

Conventions: metres, seconds, hours; x east, z south; time is **game seconds since day 1 00:00** (`int`), day 1 is day index 0. A citizen is
an index `0 .. citizens_count`; a place is an index `0 .. citizens_places` (a building, in the order the city port gave them); a building's
stable `id` is the city's, and what a save keeps.

## How it works

**A citizen is always in one episode**: doing an activity at a place until a time, or travelling to a place until a time. Nothing runs per
frame for them. A **wheel of one-minute buckets** holds each citizen at the minute their episode ends; a tick processes the buckets the clock
passed, and each citizen in one is stepped: a trip's arrival begins the activity; an activity's end settles their needs and money and **decides
the next** (utility, below), which sets off a trip, or begins the activity where they are. About 15 episodes a citizen a day.

**Every choice is a pure function of integers**: a hash of (the world seed, the citizen, the episode, the question) - there is no stream of
dice to keep in step - and of the citizen's own columns. Bars are integers (tenths of a point), times are integer seconds, scores are IEEE
`+ - * /` on floats from those, and nobody reads another citizen's state (a visit is to a friend's home, not to the friend). So:

- any machine computes any citizen's day from the seeds, and only **what the world did to them** has to be sent (hire, mission, fright, a
  body that fell behind), as a few integers a correction;
- a citizen can be **advanced alone to any moment** up to the clock (`citizens_sync`) and is exactly what the wheel makes of them; the wheel is
  bookkeeping, and stepping the clock at once, by the minute, by the second or unevenly gives the identical day (tested);
- the same city and seed make **the same people** with the same stable ids, names, homes, workplaces, wages and friends on every machine, so a
  player meets the same person every day (a person of routine is at the same desk at the same hours each workday).

## The data

Six tables a game declares (open registries, `def X from "file.lres"`).

| table | a row |
| --- | --- |
| `NeedDefs` (`CZNEED_*`, at most 8) | a need: `decay` a bar loses an hour, `start`, `warn` (below it the need pulls), `crit` (below it it overrides nearly everything), `weight`, `travel` (extra points an hour while travelling), `kind` `bar` or `money` (no bar: its pull is how thin the citizen's savings are) |
| `PlaceTags` (`CZTAG_*`) | a tag a building can carry (`bar`, `office`, `shop`): `open_from` / `open_to` (an opening window, past midnight allowed), `revenue_per_job_hour` (what the world outside pays a workplace of this tag for each hour its people work) |
| `Activities` (`CZACT_*`) | something to do: `where` (`home`, `work`, `friend`, or `tags` with `tags`), `effects` (need, points an hour), `dur_min` / `dur_max` minutes, `cost`, `pay` (a multiple of the citizen's wage an hour: overtime 1.5), `hours_from` / `hours_to` (outside them its pull is a tenth, or nil when `strict`), `weekdays` mask, `slow` (decay while doing it: sleep 0.4), `weight`, `obligation` (work: the shift decides), `needs_job`, `outdoor` (bad weather counts against it), `idle` (what nothing pulling turns into), and the **data for a body**: `anim` (animation graph state), `clip`, `prop`, `stance` (`stand`, `sit`, `lie`, `use`, `wait`) |
| `CitizenArchetypes` (`CZARCH_*`) | a kind of citizen: `weight`, `work_tags` (none: they do not work), `employment` %, `wage_lo` / `wage_hi` an hour, `shifts` (`from`, `hours`, `weight`, `days` mask, `jitter` minutes of clocking in and out, a different amount each day), `money_lo` / `money_hi`, `comfort` (savings at which money stops worrying them), `upkeep` a day, `need_weights`, `routine` / `social` / `thrift` (0 .. 100), `car_chance`, `pref_walk` / `pref_transit` / `pref_car` / `pref_taxi`, `walk_max`, `value_of_time`, `look` (a key for whoever gives them a body) |
| `CitizenNames` (`CZNAME_*`) | `part` `first` or `last`, `name` (a text key or the plain word), `weight` |
| `CitizenSettings` (`CZSET_*`, the first row) | `world_seed`, `occupancy` of homes, `walk_speed`, `walk_detour`, `est_speed`, `commute_margin`, `transit_bucket`, `scan_interval`, `r_near` / `r_mid`, `max_mid`, `day_start_weekday`, `pay_days`, `closed_loop`, `job_search` % a day, `move_per_10k`, `car_cost_per_km`, `friends`, `idle_score`, and the graph states for travelling (`anim_walk`, `anim_wait`, `anim_ride`, `anim_drive`, `anim_taxi`) |

```lres
# needs.lres
hunger { decay: 6.0, start: 70.0, warn: 40.0, crit: 15.0 }
energy { decay: 3.0, start: 75.0, warn: 55.0, crit: 20.0, travel: -1.0 }
money  { kind: "money" }

# activities.lres
sleep   { where: "home", dur_min: 240, dur_max: 600, hours_from: 21.0, hours_to: 10.0, slow: 0.4, effects: [{ need: "energy", per_hour: 8.0 }], anim: "sleep_bed", stance: "lie" }
bar     { where: "tags", tags: ["bar"], dur_min: 60, dur_max: 180, cost: 16, hours_from: 17.0, hours_to: 26.0, effects: [{ need: "fun", per_hour: 25.0 }, { need: "social", per_hour: 22.0 }], anim: "drink_stand" }
work    { where: "work", obligation: true, needs_job: true, anim: "work_desk", clip: "type_keys", stance: "sit" }
overtime { where: "work", needs_job: true, pay: 1.5, dur_min: 60, dur_max: 180, hours_from: 17.0, hours_to: 22.0 }
```

`tests/data/` holds a complete neutral set (seven needs, eleven activities, four archetypes).

## The ports

Every member has a default; unbound, the city has no buildings and nobody is made.

| port | what it asks |
| --- | --- |
| `CitizensCity` | the buildings: `count`, `id` (stable), `x`, `z`, `tags` (a bit per `PlaceTags` row), `homes` (residents it can house), `jobs`, `price` (thousandths), `district` |
| `CitizensWorld` | `now` (game seconds; -1: run on the game hours each tick gives), `weekday(day number)`, and the players: `viewers`, `viewer_x`, `viewer_z` |
| `CitizensTransit` | `eta` (seconds from departing, all in; -1 none) and `fare` of that answer, `plan` and `leg_i` / `leg_f` (the planner's legs, for a citizen on real paths), `ride_pose` (where the vehicle of a ride leg is), `taxi_eta`, `taxi_fare` |
| `CitizensCars` | `eta` (their own car), `park_secs` |
| `CitizensWeather` | `bad` 0 .. 100 |
| `CitizensBody` | `embody`, `leg`, `release` and `back_*`: the bodies (see the hand-off below) |

`adapters/` holds glue for a game that has the packages beside this one (copy a file or import it; **each is tested against the real package**):
`transit.ludic` binds `CitizensTransit` to `ludic.transit`'s planner and timetable; `crowd.ludic` binds `CitizensBody` to `ludic.crowd`'s
embodiment; `city.ludic` mirrors an authored `ludic.city` (every building of the map, its residents and jobs, its zoning rule's tags through the
game's `CzZoneTags` table) behind `CitizensCity`. Each file's head has the `bind` line. `tests/citizens_transit_test`, `citizens_crowd_test` and
`citizens_city_test` run them.

## The population

`citizens_build(cz)` reads the city through its port into places and their indexes; `citizens_generate(cz, start)` makes the people: each
building houses `homes * occupancy` of them (the fraction rounded up by a seed), and a citizen's **kind** (by weight), nature (the kind's traits
± 20), wage, savings, car, shift, friends (one housemate where the building has two, the others near in number) and **job** - their kind's
employment chance, then the nearest of a few workplaces (of the tags their kind works in) with a free job, among those a seed draws - follow from
the seed and the citizen's number. Capacity is held: no home over its residents, no workplace over its jobs. `citizens_config_seed` sets the
seed in code (it wins over the settings row); `citizens_city_changed` reads the city again after it is authored anew and **keeps the people**
(buildings are matched by stable id: a lost home rehouses them, a lost or full workplace fires them, `CZ_F_EVICTED`).

## What a citizen does next: utility

A **day's plan** is its obligations: on the first decision of a day a jobless citizen may find a job (`job_search`), a citizen may move house
(`move_per_10k`), and the shift they are on or have next is fixed (`cz_shift_window`: a night shift that began yesterday counts; the start and
end move by the citizen's `jitter` that day). Everything else is decided when it is needed, **by utility**: each activity is scored and the best
goes.

- **Relief.** For each need the activity raises, the points it would give over its length (until that need is full, within its limits) capped by
  the room left, times the need's **urgency**: `0.1 + ((100 - v) / 100)^2 * 2.5 * weight`, plus 2 under `crit`, times 0.15 above `warn` (a
  comfortable need pulls a little), times the kind's own weight. A money need's relief is the income of work done (an hour of overtime against the
  savings the citizen would like) and its urgency the **pressure** `1 - savings / comfort`, clamped to 0 .. 1.
- **What it costs.** The price against the kind's `comfort`, more for a thrifty citizen and more again as pressure rises; something they cannot
  afford is not possible at all. An activity that would make them late for the shift is shortened to fit (nothing is begun that leaves less
  than the activity's minimum before they must set out), and **at the leave-by time** (the shift's start, less the trip there, less the
  margin) they go to work.
- **When and how far.** Outside `hours_from` .. `hours_to` the pull is a tenth (nil when `strict`); a place is **open** only by its tags'
  windows, tried at the hour of arrival; an hour of travelling costs 1.6; an outdoor activity loses the weather's share (and is off in a storm).
  A place is the best of **three a citizen's seed draws** among those carrying the tags (the nearest that is open), so nothing scans the city.
- **Nature.** Habit (what they did in this three-hour slot before), whim (less for a person of routine) and company (a social person's visits)
  scale the score; they never decide whether anything pulls at all, so a citizen with everything full idles.
- **Forced, afraid, nothing.** A mission's forced activity (`citizens_force`) wins; a frightened citizen goes home and stays in; below
  `idle_score` nothing pulls and they idle at home for 40 to 130 minutes (or until they must set out).

The duration of an activity is how long it takes to fill the need it is for, varied 10 %. The bars fall by their decay (slowed by `slow`) and the
activity's effect over each episode's exact length.

## The economy loop

Wages, prices and upkeep close a loop that the needs drive:

- **Wages per shift.** Work pays the citizen's hourly wage for the hours worked (overtime: times its `pay`), **accrued at the end of the episode
  from the workplace's till** and paid out on payday (`pay_days`, default daily), scaled by the workplace's **wage factor** for the day.
- **A till.** Customers' spending goes into the place's till (`cost` of the activity, times the place's price); each morning the world outside
  adds `revenue_per_job_hour` of each of the place's tags for the hours its people work; and the workplace works out **the share of a full wage it
  can pay today** from the till and the day's payroll (`closed_loop`; a workplace that cannot pay in full says `CZ_F_BROKE`). Above three days' payroll
  the excess leaves as the owners' profit (`citizens_stat_leak`).
- **Upkeep.** Every citizen pays their kind's `upkeep` a day (rent and bills), settled at their next decision.
- **Needs push choices.** Thin savings raise money pressure, which raises the pull of overtime and lowers that of anything that costs; low energy
  sends them home to sleep; a hungry citizen with little money eats at home, not out. A workplace with fewer customers pays less, its
  people have less to spend, and so on.

**Money is conserved**: what the citizens hold changes only by wages, spending (activities and trips) and upkeep, plus `citizens_give`
(tested to the unit over four days). `citizens_money_total`, `citizens_stat_*` and `citizens_place_*` are the economy's dashboard.

## Getting about

For each trip the citizen weighs the ways open to them and takes the cheapest in money and their own value of time, divided by how much they like
the mode, with the same small nature-shaped variation each day for a commute (a person of routine takes the same way):

| mode | time and cost |
| --- | --- |
| walk | street distance (`walk_detour`) at `walk_speed`; always possible; a long walk past the kind's `walk_max` is dear; bad weather multiplies it |
| transit | `CitizensTransit.eta` **from the next multiple of `transit_bucket`** (the wait is part of the trip), its fare; everything in (walking, waiting, riding) - a mixed trip (walk, metro, walk) is one plan; plans are shared through a cache keyed on (from, to, bucket), which is only a cache: the answer is a pure function |
| car | `CitizensCars.eta` plus `park_secs`, `car_cost_per_km`; **only if they own one and it is where they are** - it is left where they drove it, so a person who took the bus cannot drive home |
| taxi | `taxi_eta` and `taxi_fare`, if they can pay |

## How closely they are simulated

| tier | what a citizen is | cost |
| --- | --- | --- |
| **FAR** (`CZ_LOD_FAR`) | an event chain: at a place until a time, or travelling until one. A traveller's place is worked out from their trip when asked | nothing between events |
| **MID** (`CZ_LOD_MID`) | on real paths: a trip becomes **legs** (the planner's walk / wait / ride / walk, or one straight leg by foot, car or taxi; a ride leg's place is the vehicle's, from `ride_pose`), their position a pure function of the legs, their episodes ending at the **second**, not the minute | about 80 ns a citizen a tick |
| **NEAR** (`CZ_LOD_NEAR`) | handed to the game's bodies through `CitizensBody`: a person at a building, a pedestrian, a driver | the game's |

Who is near a player is found from the places in range (and who is at them) and from the people now travelling, **not** the population: every
`scan_interval` the grid of places is walked for each viewer and the traveller list scanned, and a citizen out of range for three scans is let go.
`citizens_witness`, `citizens_accident`, `citizens_near` and `citizens_at_place` ask the same lists.

**Promotion only adds detail; the far state is the truth.** The planner's legs are the trip the far state only timed (the trip's duration *is*
the plan's, from the same bucketed departure), so a player who follows someone across the boundaries sees the same person at the same place at
the same time, and a player being there changes nothing about anyone's day (tested: the same digest with a player in the office as without).

### The hand-off to bodies (crowd, cars, NPCs)

```text
embody(id, what, archetype, activity, x, z, goal_x, goal_z, seconds_left) -> bool     # the game made a body; it now owns its position
leg(id, what, activity, has_goal, goal_x, goal_z, seconds_left)                        # the citizen's leg or activity changed
release(id) -> bool, then back_x / back_z / back_arrived / back_left / back_fear       # the citizen left range, or became something else
citizens_body_at(cz, id, x, z)      # each tick: where the body is        citizens_body_lost(cz, id)    # the game lost it (killed)
```

`what` is `CZ_BODY_AT_PLACE` (an NPC doing the activity at a building: the `anim` / `clip` / `prop` / `stance` of the row), `CZ_BODY_PEDESTRIAN`
(a walk, or the walking and waiting legs of a transit trip), `CZ_BODY_VEHICLE` (their own car or a taxi: the game's cars) or `CZ_BODY_RIDER` (inside
a transit vehicle: **no body**, the `release` is called if one was there). The rules:

1. **The body owns its position while it lasts** and walks or drives its leg; citizens never moves it. The schedule goes on beside it: a citizen
   whose leg ends is told the next with `leg`, or (a different kind of body) `release` and a new `embody`.
2. **A body that fell behind or ran ahead moves the citizen's arrival on hand-back**: for a pedestrian on a walking trip, the remaining walk
   from where the body is, at the citizen's speed, becomes the new end of the trip (when it differs from the schedule by more than 15 s, and
   logged for clients). A body at a building changes nothing.
3. **A body that is lost** (`citizens_body_lost`) leaves the citizen to the schedule. `back_fear` (0 .. 100) makes the citizen afraid for that
   many minutes.
4. `citizens_anim(cz, id)` is the graph state of what they are doing now - the activity's, or the settings' for each leg of a trip - as data;
   `citizens_clip`, `citizens_prop` and `citizens_stance(activity)` likewise.

`adapters/crowd.ludic` is this contract on `ludic.crowd` (`crowd_embody`, `crowd_set_leg`, `crowd_release` and its `crowd_handoff`, the crowd's ped
type chosen by the archetype's `look`, the act from `stance`, the key from `anim`); a per-frame `czc_pump` reports the peds' places and the
bodies the crowd lost.

## What happens to them

Each is a verb, a fact, and on the host a logged correction:

| verb | |
| --- | --- |
| `citizens_hire(i, place)` / `citizens_fire(i)` | a job; `CZ_F_HIRED` / `CZ_F_FIRED` |
| `citizens_move(i, home)` | moves house (slow churn also moves a few a day by itself); `CZ_F_MOVED` |
| `citizens_force(i, activity, place, seconds)` / `citizens_unforce` | a mission's word: someone at a place stops now, someone on the way does it on arriving; it ends by itself (`CZ_F_FORCE_DONE`) |
| `citizens_hold(i, secs)` | held in conversation: what they are doing ends later |
| `citizens_witness(x, z, r, kind, severity)` | the people out in the street (simulated closely, not riding) within `r` saw a crime: `CZ_F_WITNESSED` - **the game routes it to `ludic.wanted`** - and they go home afraid |
| `citizens_accident(x, z, r, kind, severity)` | walkers near it are caught up and held two minutes; `CZ_F_ACCIDENT` |
| `citizens_give(i, amount)`, `citizens_befriend(i, other)`, `citizens_set_car(i, has)`, `citizens_replan(i)`, `citizens_watch(i, on)`, `citizens_place_set_cash(p, n)` | money or a fine, a friendship (`CZ_F_FRIENDS`), a car bought or sold, a fresh decision now, every step of one citizen told as facts, a till set |

Facts (`citizens_facts(cz) -> Queue<CitizenFact>`, `{ what, id, a, b, c, t }`): `CZ_F_ARRIVED`, `_DEPARTED`, `_STARTED` (only for watched or closely
simulated citizens: a far citizen costs no fact), `_HIRED`, `_FIRED`, `_MOVED`, `_PAID`, `_WITNESSED`, `_ACCIDENT`, `_FRIENDS`, `_PROMOTED`, `_DEMOTED`,
`_BROKE`, `_CRITICAL`, `_FORCE_DONE`, `_EVICTED`.

Queries: who (`citizens_archetype`, `_home`, `_work`, `_home_id`, `_work_id`, `_wage`, `_name` from the registry by seed, the traits, `_friend`), what
and where (`citizens_sync(i, t)` then `_doing`, `_activity`, `_place`, `_from`, `_until`, `_mode`, `_lod`, `_x`, `_z`, `_leg`, `_goal_x/_z`, `_anim`), what
they have (`_money`, `_need(i, k)` as of now, `_pressure`), finding people (`_near`, `_at_place`), places (`citizens_place_*`), the economy (`citizens_stat_*`,
`_money_total`, `_employed`, `_unemployed`, `_count_doing`).

## A host and its clients

Every machine runs the same far simulation from the same seeds. The host (`citizens_config_host(cz, true)`, the default) **logs what the world did**
as eight integers a correction: `citizens_log_since(cz, seq, out)`. A client (`citizens_config_host(cz, false)`) applies them with
`citizens_log_apply(cz, entries, n)`: one whose moment it has reached is applied now, after advancing that citizen alone to that moment (`citizens_late`
counts one that arrived after its moment), a later one waits for the clock. `citizens_digest(cz)` is one number for the whole population - two machines whose
corrections agree give the same - and `citizens_export(cz, i, out)` / `citizens_import(cz, i, ints)` send one citizen's whole state to put a drifted one right.
Tested: a client stepping its clock unevenly, given the host's log, lands on the host's digest.

## Save

Section `"citizens"`, version 1 (`citizens_system()` is `"citizens"` in `PH_SIMULATE`): **seeds and deltas**. The seed, the city's hash and the size; the
citizens whose home, job, shift, wage, car or friends differ from what the seed makes (by stable building id); what they hold (savings as a list, wages owed, who is
afraid), the tills and the counts. Where they are and what they were doing is not kept: a load makes the people again, runs the far simulation on for a warm-up
(four hours, `citizens_config_warmup`) and lands at the saved moment with everyone somewhere plausible. A city that changed since the save makes a fresh
population and says so (`citizens_load_status`: `CZ_SAVE_OK`, `_CITY_CHANGED`, `_SIZE_CHANGED`).

## Zero allocation

Every list is sized when the city is built or the population made; a tick allocates nothing. Tested: two warm days and then a game day near a player and
far, the heap does not grow by a byte (`tests/citizens_test.ludic`).

## Performance

`tests/citizens_bench_test.ludic` (one thread, Apple silicon; the ports are fakes, so this is the citizens' own logic: decisions, trips, the economy,
the wheel). **200 000 citizens** (124 000 employed, 4 920 buildings, made in about 75 ms) over a simulated day at far LOD:

| | |
| --- | --- |
| a day, in 1 440 one-minute ticks | **2.2 - 2.4 s in all** (2.94 million episodes, about 790 ns an episode, 11 us a citizen a day) |
| a one-minute tick | **about 1.6 ms on average**, the worst of the day 6 - 8 ms (the morning and evening shift changes, spread by `jitter`) |
| a second day (warm) | the same |
| an hour in one-second ticks | about 70 us a tick, nearly all of it the episodes that fell due |
| **about 500 citizens on real paths** (504, 65 of them NEAR and handed to fake bodies) at 60 ticks a second | **about 40 us a tick** (80 ns a citizen a tick), the worst tick under 3 ms |

With `ludic.transit` behind the port a transit trip costs the planner's time on a cache miss (about 70 us on a 576-stop grid): what matters is the
number of distinct commutes, not the people.

## Tests

`ludic test packages/ludic.citizens` - `citizens_test` (46 tests: the population from a city's capacity and stable ids, jobs near home by kind, a workday and a
night shift and a Saturday, money conserved, the day's shape, hours and weather, the same day however the clock is stepped, a citizen advanced alone, hunger,
money pressure, the kept shift, walking and transit and car and taxi and weather, the economy loop and a poor till, close simulation and bodies and hand-back,
the legs of a trip, events, a host and a client, late corrections, export and import, the save and a changed city, the authored city changing, the editor's
link, no allocation), `citizens_bench_test`, and the three adapter tests on the real transit, crowd and city packages.

## v2

A dynamic price that follows demand; a citizen who quits, is promoted or retrains; a household with children and partners whose days depend on each other;
friendships that form in the venues they share; births, ageing and deaths (a body that is killed today leaves the schedule alone); the citizens' rides counted
into `ludic.transit`'s loads as aggregate demand; `ludic.cars` for their own car's body and its parking; a sleep that follows the night and the light; a
work break for a long shift; indoor NPC positions (a desk, a stool) as the city's interiors give them; a spatial index of travellers for a city of millions.
