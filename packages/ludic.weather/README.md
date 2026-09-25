# ludic.weather

The sky as a chain of spells: clear, cloud, rain, a storm, snow - or whatever kinds the game
hands in. Each spell lasts a few game hours, eases in and out at its edges, sets the wind and
wets the ground, and gives way to the next by odds the game may lean on (a season, a wet week).
A forecast is drawn each morning, and the story can ask for a front or for a clear night. Uses
[`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.weather"
```

A kind is the game's number: its place in the list handed to `weather_kinds`. The package knows
what a kind DOES (it is wet, it throws lightning, it holds the cold) and never what it is called
in a sentence; the game draws the sky and says the notices.

Only the machine that owns the world runs the spells. Every machine eases the ground's wetness
and throws its own lightning out of a storm it is told of (`weather_told`), from the package's
own dice - never the world's.

## The kinds

```ludic
property WeatherKind {
  name: string           # for weather_name
  clear: bool            # the kind a sky eases out to (amount 0); the first one starts a trip
  wet: bool              # rain or snow is falling (weather_wet)
  soak: float            # how wet the ground gets under it, 0..1
  overcast: float        # times the amount: weather_overcast
  cold: float            # times the amount: weather_cold, in the game's units
  wind: float            # the strength the wind builds toward
  wind_dir: float        # radians the wind blows toward; below 0, the valley's daily turn
  thunder: bool          # a storm: lightning every 9-34 s while the amount is over a half
  spell_lo, spell_hi     # game hours a spell lasts
  odds: []float          # weights for the next spell, one per kind
}
```

## The port

```ludic
property WeatherWorld {
  owns_world: fn() -> bool        # does this machine run the world? (unbound: yes)
  hours: fn() -> float            # the hour, for the wind's daily turn (unbound: noon)
  is_night: fn() -> bool          # a front clearing at night is no WEATHER_CLEARED
  odds: fn(int) -> []float        # the next spell's weights from a kind (unbound: the kind's own)
  bias: fn() -> int               # what the story wants now: WEATHER_NO_BIAS, _WANT_WET, _HOLD, _WANT_CLEAR
  front: fn() -> int              # the kind a wanted front comes as (unbound: the first wet kind)
  front_hours: fn() -> float      # the least a wanted front lasts (never under 5)
  seed: fn() -> int               # a new trip's dice
}
```

The bias is asked every tick on the owner. `WANT_WET` on a dry sky forecasts a front
(`WEATHER_FRONT`), due within an hour and a half; `HOLD` keeps the current spell going at least
1.2 hours more; `WANT_CLEAR` clears within half an hour and keeps it clear. The game decides WHEN
it wants them (daylight, a tarp up, a stars job open).

## API

| | |
| --- | --- |
| `weather_bind(w)`, `weather_kinds(ks)`, `weather_config_wind(down, up, from, to)` | the port, the kinds, and the valley's wind: toward `down` by night, toward `up` from `from` to `to` |
| `weather_run(dt, gh)` | one step (the system's tick does this from `Tick.dt` and `Tick.hours`) |
| `weather_morning()` | a new day's forecast: seven times in ten it becomes the next spell |
| `weather_reset()` | a new trip: the first clear kind, nothing forecast, dice from the seed |
| `weather_set(kind, next, left)`, `weather_set_wind(s, dir)`, `weather_set_ground(w)`, `weather_set_flash(f)` | the sky outright (staging, tests) |
| `weather_told(kind, next, left, amount, wind, dir, forecast)` | what the owner says the sky is; a new spell is a fact here too |
| `weather_state()`, `weather_next()`, `weather_left()`, `weather_amount()`, `weather_forecast()`, `weather_forced()` | the spell |
| `weather_wet()`, `weather_overcast()`, `weather_cold()`, `weather_wind()`, `weather_dir()`, `weather_ground_wet()`, `weather_flash()` | what it does |
| `weather_after_front()`, `weather_wet_yesterday()` | the half hour of clear light after a front; whether yesterday had rain or snow in it |
| `weather_kind(k)`, `weather_kind_count()`, `weather_name(k)`, `weather_draw_from(w, from, roll)` | the kinds, and the draw itself |
| `weather_facts() -> Queue<WeatherFact>` | `{ what, kind, from }`: `WEATHER_BEGAN` (a new spell), `WEATHER_CLEARED` (a wet spell gave way to clear sky by day), `WEATHER_THUNDER`, `WEATHER_FRONT` (a wanted front is forecast) |
| `weather_system() -> System` | `"weather"`, `PH_SIMULATE`: reset, tick, and its save section (`weather_save`, `weather_load`: the spell, the forecast, the wind's direction, the ground, the dice) |

## Tests

```bash
ludic build packages/ludic.weather/tests/weather_test.ludic --headless -o /tmp/weather_test && /tmp/weather_test
```
