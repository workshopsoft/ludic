# ludic.clock

One clock for a whole world: the hour, the day, the moon's place in its month, and where the day
falls in a calendar the game describes - month, year and season as a pure function of the day.
Uses [`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.clock"
```

The clock never runs the morning. A day turning - past midnight, or by `clock_new_day` after a
night slept - is a `DayTurned` fact on `clock_days()`, and the game drains it into whatever its
morning is (weather, restocking, the animals' day). Only the machine that owns the world moves
the hour; another machine is told it (`clock_set_hours`, `clock_set_day`, `clock_set_moon`).

## The numbers as data

The day's length, the start hour, the night, the moon and the calendar are one row of the open registry
`ClockSettings` (`def ClockSettings from "clock.lres"`; the first row is used, read at the first
`clock_reset` or `clock_load`):

```lres
world {
  day_minutes: 24.0               # real minutes a game day takes (24: a real minute is a game hour)
  start_hours: 8.0, night_from: 20.0, night_to: 6.0
  moon_days: 29.5, moon_lo: 0.0, moon_hi: 1.0
  month_days: 30
  seasons: [0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 0]   # each month's season; its length is the year
}
```

`clock_config`, `clock_config_moon`, `clock_calendar` and `clock_set_scale` are the older way and still
win: what a game sets in code is not overwritten by the row's part. With no row the numbers are the
ones the clock always had.

## The port

```ludic
export port ClockWorld {
  owns_world: fn() -> bool = ...    # does this machine run the world? (unbound: yes)
  rest_scale: fn() -> float = ...   # how much everyone's rest speeds the clock (unbound: 1)
  seed: fn() -> int = ...           # a seed for a new trip's moon (unbound: 1)
}
```

The game fills it once, where it is put together, and may leave any member out:

```ludic
bind ClockWorld { owns_world: fn ses_owns_world, rest_scale: fn rt_rest_scale, seed: fn rt_clock_seed }
```

## API

| | |
| --- | --- |
| `bind ClockWorld { ... }` | the port (a declaration, not a call) |
| `clock_config(start_hours, night_from, night_to)` | when a trip starts, and which hours are night |
| `clock_config_moon(days, lo, hi)` | the moon's month in days, and the part of it a new trip starts in |
| `clock_calendar(month_days, season_of_month)` | a month's length, and each month's season (the list's length is the year) |
| `clock_dates(month_starts)` | the real day of the year (1 = 1 January) each month begins on: a game day then lands on a date |
| `clock_set_scale(s)`, `clock_scale()` | game seconds per real second |
| `clock_rate()`, `clock_hours_in(dt)` | the rate with the rest included, and the game hours `dt` real seconds are worth |
| `clock_advance(gh)` | run the hours on (the system's tick does this from `Tick.hours`); past midnight the day turns |
| `clock_new_day()` | turn the day now (the caller sets the hour first) |
| `clock_reset()` | day one at the start hour, the moon from the seed |
| `clock_day()`, `clock_hours()`, `clock_moon()`, `clock_hhmm()`, `clock_is_night()` | what the world asks |
| `clock_month()`, `clock_year()`, `clock_day_of_month()`, `clock_season()`, `clock_days_to_change()` | today in the calendar |
| `clock_doy()`, `clock_doy_of(d)` | the day of the year a game day lands on (a whole day; 1 with no dates) |
| `clock_month_of(d)`, `clock_year_of(d)`, `clock_day_of_month_of(d)`, `clock_season_of(d)`, `clock_days_to_change_from(d)`, `clock_first_day_of(season)` | any day in the calendar |
| `clock_days() -> Queue<DayTurned>` | the facts: `{ day, how }`, `how` one of `DAY_STAYED_UP`, `DAY_SLEPT` |
| `clock_system() -> System` | `"clock"`, `PH_INPUT` (first, so every later system reads this frame's hour): reset, tick, and its save section (`clock_save`, `clock_load`: day, hours, moon) |

## Tests

```bash
ludic build packages/ludic.clock/tests/clock_test.ludic --headless -o /tmp/clock_test && /tmp/clock_test
```
