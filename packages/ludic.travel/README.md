# ludic.travel

Points a player comes to know and fast-travels between: waypoints, shrines, towns, camps. How each
is unlocked (a start, a walk near it, a use, a world condition, the story), what a trip costs in
coins and game hours, the loading asked through a port, and the markers a map draws. Uses
[`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.travel"
```

The game fills three open registries, usually from resource files: `def TravelPoints from
"points.lres"`, `def TravelRules from "travel_rules.lres"`, `def MarkerKinds from "markers.lres"`.
The package's own first rows are `free` (rule 0: no cost, no delay) and `point` (marker kind 0), so a
point that names no rule or marker means something. Every table is `@ByKey`: the save names things
by key, so the order is free. Names and blurbs are text keys the game translates.

## Data

```ludic
TravelPoint { key, name, blurb, region, kind, map, x, y, z, yaw, unlock, radius, flag, unlock_cost,
              needs, rule, marker, fast, hidden }
TravelRule  { key, base, per_km, cross_map, free_within, max_cost, hours_per_km, hours_cross_map,
              delay, timeout, cooldown, allow }
MarkerKind  { key, name, icon, color, priority, size, min_zoom, layer }
```

- **`unlock`** is one of `TRAVEL_UNLOCK_START` (known from a new game), `_NEAR` (the player walked
  within `radius` metres), `_USE` (`travel_use`, for `unlock_cost` coins), `_FLAG` (the world says
  `flag` is true) or `_STORY` (only `travel_discover`). `needs` lists points that must be known first
  for a near, use or flag unlock.
- **A trip's price** is `base + per_km * km + cross_map` (the last only when the point's `map` differs
  from the player's), free within `free_within` metres, never above `max_cost` (0: no ceiling).
  Game time is `hours_per_km * km (+ hours_cross_map)`. `delay` is the least the loading screen
  shows, `timeout` how long the world gets before the trip fails and the coins come back, `cooldown`
  the seconds before the next trip. `allow` is a named condition the world must say is true
  ("no_combat").
- **`fast: false`** is a point that is discovered but never travelled to; **`hidden: true`** keeps it
  off the map until known.

## The ports

Every member has a default: unbound, the player stands at the origin, every condition is true, money
is no object, the world loads at once and time does not pass.

```ludic
export port TravelWorld { px, py, pz: fn() -> float; map: fn() -> string; condition: fn(string) -> bool;
  load: fn(int) -> bool; ready: fn() -> bool; arrive: fn(int) -> void; abort: fn(int) -> void;
  pass_time: fn(float) -> void }
export port TravelPurse { money: fn() -> int, spend: fn(int) -> bool, refund: fn(int) -> void }
```

`load(point)` begins loading the destination (false refuses the trip, unpaid). The package polls
`ready()` each tick; when it is true and the rule's `delay` has passed it calls `pass_time(hours)` and
`arrive(point)`, and the game moves the player. The package never loads or moves anything itself.

## API

| | |
| --- | --- |
| `travel_known(p)`, `travel_known_count()`, `travel_count()`, `travel_find(key)`, `travel_visits(p)` | what the player knows |
| `travel_discover(p)`, `travel_discover_key(key)`, `travel_discover_all()`, `travel_forget(p)` | the story's hand |
| `travel_use(p) -> why` | a shrine's touch: unlocks a `_USE` point, pays `unlock_cost`; `TRAVEL_OK` or why not |
| `travel_look()` | one look at the player's place and the flags (the tick does it four times a second) |
| `travel_cost(p)`, `travel_hours(p)`, `travel_distance(p)`, `travel_needs_met(p)` | pricing |
| `travel_why_not(p) -> why`, `travel_can_go(p)` | `TRAVEL_OK`, or `_NO_SUCH`, `_NOT_KNOWN`, `_NOT_FAST`, `_HERE`, `_COOLING`, `_BLOCKED`, `_TOO_POOR`, `_BUSY` |
| `travel_go(p)`, `travel_go_key(key)`, `travel_cancel()` | a trip: checked, paid, the load begun; cancel gives the coins back |
| `travel_set_here(p)`, `travel_here()`, `travel_busy()`, `travel_dest()`, `travel_cooldown()` | where the player last was and what is under way |
| `travel_menu_into(region, out) -> n` | the points on offer, nearest first, into the caller's list |
| `travel_markers_into(x0, z0, x1, z1, zoom, layer, out) -> n` | the map's markers in a view, lowest priority first, into the caller's own `[]MarkerView` (kept: a frame makes nothing) |
| `travel_marker_add(kind, x, z, tag, label) -> id`, `travel_marker_remove(id)`, `travel_marker_remove_tag(tag)`, `travel_marker_move(id, x, z)`, `travel_marker_show(id, on)`, `travel_marker_label(id)` | markers of the game's own (a quest, a player's pin) |
| `travel_facts() -> Queue<TravelFact>` | `{ what, point, cost, why, marker }`: `TRAVEL_DISCOVERED`, `_STARTED`, `_ARRIVED`, `_REFUSED`, `_FAILED`, `_MARKER_ADDED`, `_MARKER_REMOVED` |
| `travel_reset()`, `travel_save()`, `travel_load(v, version)`, `travel_system()` | `"travel"`, `PH_SIMULATE`: the clock of a trip, cooldown and the look; saved by key: what is known, visits, where the player was, the markers |

A trip under way is not saved: a load starts at rest.

## Tests

```bash
ludic test packages/ludic.travel
```
