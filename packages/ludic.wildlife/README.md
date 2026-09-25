# ludic.wildlife

The animals of a valley: the ranges each species keeps to, and every animal's day - wander about
home, go down to water and forage when thirst and hunger climb, notice the players and decide what
to make of them, flee, charge, come to food and lures, walk into snares; birds circle, glide down,
peck and lift off. Uses [`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.wildlife"
```

The package owns the animals' state, the steering, the senses, the alert, feeding and lures,
spawning within ranges, its own dice (an `Rng`, never `Random.*`) and its own save section. It
never draws anything: the game makes an actor when the port says an animal was `born` and keys its
drawing by the animal's `key`, and it never decides what anything is worth - a feeding, a catch, a
shove, a print are facts the game drains.

## Species are data

The game hands the table in, once: `wildlife_species_add(s)` per species, in its own order, so the
entry's place is the species number. A `WildSpecies` is `key`, `walk`, `run`, `flee` (its nerve,
m), `home` (how far it roams), `habitat` (`WILD_MEADOW`, `_FOREST`, `_SHORE`, `_CLIFF`), `tracks`,
`size` (0 small - a snare holds it), `diet` (`WILD_PLANTS`, `_FISH`, `_HAY`, `_SEED`), `flies`,
`tame`, `charges`, `forget` (alert points a second it lets go of), `land_shy`, `land_chance`,
`keep_away`, `range` (how wide one of its ranges is) and `scale`.

## The port

```ludic
export port WildlifeWorld {        # every member has a default: a flat dry meadow at noon, one silent player
  ground, water, slope: fn(float, float) -> float     # the ground, the water's surface, the gradient
  forest: fn(float, float) -> bool
  sight: fn(ax, ay, az, bx, by, bz) -> bool           # nothing between the two points
  players: fn() -> int                                # slots; player_on(p), player_x / _y / _z(p)
  hidden, noise, scent, stillness                     # per player: in a hide, 0..1, 0..1, WILD_MOVING / _STILL / _SITTING
  hour, light, winterness, wind, wind_dir: fn() -> float   # the clock, how well it sees now, the season, the weather
  wariness, charge_reach: fn() -> float               # every nerve times, how close a charger lets you come
  taught: fn() -> bool                                # feeding is being taught: food carries 175 m, feeders mind less
  about: fn(WildAnimal) -> int                        # WILD_ABOUT, WILD_AWAY (lying up) or WILD_GONE (a legend's hours ended)
  ranges, per_range: fn(int) -> int                   # a species' ranges on this map, and how many live in each
  spot: fn(WildAnimal, bool, WildSpot) -> bool        # water (true) or forage for it, filled in
  lures: fn() -> int                                  # how many things to ask `lure` about
  lure: fn(int, WildLure) -> bool                     # the i-th, filled in, when it is food, a lure or an empty snare
  present: fn(int) -> bool                            # a spot or lure by uid is still there
  next_id: fn() -> int                                # an animal's id across machines
  born: fn(WildAnimal) -> void                        # draw it
  placed: fn(WildRange, int) -> void                  # a range was set out: put its water and forage down
}
```

## API

| | |
| --- | --- |
| `wildlife_species_clear()`, `wildlife_species_add(s) -> int`, `wildlife_species(sp)`, `wildlife_species_count()` | the table |
| `WildAnimal`, `wildlife_all()`, `wildlife_count(sp)`, `wildlife_total()`, `wildlife_by_nid(nid)`, `wildlife_count_all()` | the animals; `state` is `WILD_IDLE` .. `WILD_LAND` |
| `wildlife_new(sp, x, z, legend)`, `wildlife_make(sp, x, z, legend, yaw, variant, scale, nid)`, `wildlife_remove(a)`, `wildlife_clear()` | making one off the package's dice or exactly as given (a guest's copy), and taking one away |
| `wildlife_spawn(x0, z0)`, `wildlife_morning() -> int`, `wildlife_repopulate() -> int`, `wildlife_seed(n)` | a valley filled; each morning the ranges move with the season and each range under its target gets one back, out of every player's sight |
| `WildRange`, `wildlife_ranges()`, `wildlife_range(i)`, `wildlife_range_dist(r, x, z)`, `wildlife_range_alive(i)`, `wildlife_ranges_visit(x, z)`, `wildlife_range_found_near(sp, x, z)`, `wildlife_ranges_migrate()` | ranges, found by standing in them |
| `wildlife_habitat_ok(hab, x, z)`, `wildlife_find_spot(hab, x0, z0, d0, d1)`, `wildlife_spot_x()`, `wildlife_spot_z()` | the right ground, and a spot of it |
| `wildlife_tick(dt, gh)`, `wildlife_tick_ground(a, dt, gh)`, `wildlife_tick_bird(a, dt)`, `wildlife_stride(a, dt)`, `wildlife_hold(on)` | the step; `pinned` on an animal leaves it where it stands |
| `wildlife_alert_rate(a, p, d)`, `wildlife_alert_decay(a, p)`, `wildlife_downwind(a, p)`, `wildlife_can_see(a, p)` | what it makes of player p |
| `wildlife_in_snare(uid)`, `wildlife_release(a)` | a snare's catch |
| `wildlife_saw(sp) -> bool`, `wildlife_seen(sp)`, `wildlife_seen_mask()`, `wildlife_set_seen(m)`, `wildlife_mark_fed(sp)`, `wildlife_fed_mask()`, `wildlife_fed_any()`, `wildlife_set_fed_any(b)` | this player's record |
| `wildlife_put_away()`, `wildlife_bring_back()`, `wildlife_away()` | a machine drawing another's animals keeps its own aside |
| `wildlife_facts() -> Queue<WildFact>` | `WILD_SPOTTED`, `_FLED`, `_FED` (`lure`, `owner`, `diet`), `_CAUGHT` (`lure`, `owner`), `_CHARGED`, `_SHOVED` (`player`), `_PRINT`, `_SCAT`, `_BED`, `_WENT` |
| `wildlife_system() -> System` | `"wildlife"`, `PH_SIMULATE`, no tick (the game steps it where the world is owned): reset, and its save section - the record and the found ranges |

The alert is net: what a player's sight, scent and noise add is weighed against what the animal
forgets every tick, so it SETTLES at a level the distance sets rather than climbing to 100 and
sticking there - `wildlife_test` holds where it settles, not only how it rises.

## Tests

```bash
ludic test packages/ludic.wildlife
```
