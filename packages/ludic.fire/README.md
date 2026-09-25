# ludic.fire

A camp fire: minutes of fuel that burn down in game time, twice as fast in the rain with nothing
over the ring, the hours it held under cover, the warmth it gives at a distance and whether it
will cook. Uses [`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.fire"
```

The package never draws the fire, never says a line and never touches a pack: lighting and
feeding are three steps so a machine that does not own the world can ask the one that does -
`fire_decide(wood)` says what it would come to, `fire_cost(how)` what it costs in wood, and
`fire_apply(how)` does it (only on the owner). The game takes the wood and says the line.

## The port

```ludic
export port FireWorld {            # every member has a default, so any may be left out
  owns_world: fn() -> bool         # does this machine burn it? (unbound: yes)
  is_wet: fn() -> bool             # rain or snow is falling on the ring (unbound: no)
  sheltered: fn() -> bool          # something is over the ring (unbound: no)
  allowed: fn() -> bool            # no fire ban (unbound: yes)
}
```

## API

| | |
| --- | --- |
| `fire_config(light_wood, light_minutes, log_minutes, low_minutes)`, `fire_config_reach(warm, cook)` | the numbers (3 logs, 120 minutes, 60 a log, low under 15; warms within 3.6 m, cooks within 3.5 m) |
| `fire_decide(wood) -> int`, `fire_cost(how) -> int`, `fire_apply(how)`, `fire_light_wood()` | `FIRE_NO_WOOD`, `FIRE_NO_LOG`, `FIRE_BANNED`, `FIRE_SOAKED`, `FIRE_LIGHT`, `FIRE_FEED` |
| `fire_lit()`, `fire_fuel()`, `fire_low()`, `fire_rain_hours()` | the fire (fuel in game minutes) |
| `fire_warms(dist)`, `fire_cooks(dist)` | lit, and a body that close is warmed / can cook on it |
| `fire_run(gh)` | `gh` game hours of burning (the system's tick) |
| `fire_out()`, `fire_set_burning(fuel)`, `fire_set_rain_hours(h)` | quietly out, or burning, or the rain hours outright (the night, staging, tests) |
| `fire_told(lit, fuel, say)` | what the owner says the fire is; going out is a fact when `say` |
| `fire_morning()`, `fire_reset()` | the rain hours start again; a new trip |
| `fire_facts() -> Queue<FireFact>` | `{ what, fuel }`: `FIRE_LIT`, `FIRE_WENT_OUT`, `FIRE_LOW_FUEL` |
| `fire_system() -> System` | `"fire"`, `PH_SIMULATE`: reset, tick, and its save section (`fire_save`, `fire_load`: lit, fuel, the rain hours) |

## Tests

```bash
ludic test packages/ludic.fire
```
