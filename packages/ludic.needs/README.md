# ludic.needs

A body's four needs - warmth, food, water and energy, each a bar of 0..100 - what an hour of
doing something costs them, and the countdown to a collapse when one runs out. Uses
[`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.needs"
```

The package owns the rates (a full bar is a day at a real trip's median, about fourteen hours at
the hardest sustained work, two days at rest) and the countdown. It never decides what a collapse
COSTS: a need at zero is `NEEDS_CRITICAL`, ten seconds later it is `NEEDS_COLLAPSED`, and the game
walks the player out, takes their money, or puts them down for a teammate. Say it happened with
`needs_went_down()`, which counts it.

## The port

```ludic
export port NeedsWorld {           # every member has a default, so any may be left out
  activity: fn() -> int            # NEEDS_STILL, _WALK, _RUN, _SIT, _SWIM, _SWIM_HARD, _FLOAT, _DIVE
  resting: fn() -> float           # energy an hour sitting gives back (unbound: 40)
  warmth: fn() -> float            # warmth an hour from the surroundings: sun, night, weather, a fire, the water (unbound: -2)
  keep: fn() -> float              # the fraction of warmth being lost that clothing keeps (unbound: 0)
  hot: fn() -> bool                # the midday sun: thirst half again faster
  effort: fn() -> float            # walking and running energy, times (the boots)
  drain: fn(int) -> float          # a need's drain, times (difficulty, a survey's rule)
  bonus: fn(int) -> float          # a need's gain an hour from outside (the effects)
  thirst: fn() -> bool             # thirst is a need at all (unbound: yes); off, water holds full
  gentle: fn() -> bool             # the needs stop at 22: no countdown, no collapse
  held: fn() -> bool               # the body is already down: the countdown waits
}
```

## API

| | |
| --- | --- |
| `NEED_WARMTH`, `NEED_FOOD`, `NEED_WATER`, `NEED_ENERGY`, `NEED_COUNT` | the needs |
| `needs_level(k)`, `needs_warmth()`, `needs_food()`, `needs_water()`, `needs_energy()`, `needs_lowest()` | the bars |
| `needs_last_legs()`, `needs_last_need()`, `needs_collapses()` | the countdown's seconds (0: none), its need, and how many times the body went down |
| `needs_pace()` | the walk's pace, times: full above fifty on each need, 0.6 at nothing, and 0.6 more on last legs |
| `needs_can_run()` | energy over 8, and warmth, food and water over 20 |
| `needs_feed(k, n)`, `needs_meal(food, water, energy)`, `needs_set(k, v)`, `needs_floor(k, v)` | the verbs; every bar is held to 0..100 |
| `needs_after_night(rested, food_lost, water_lost)` | energy to `rested`, food never under 6, water never under 5 |
| `needs_went_down()`, `needs_helped_up()`, `needs_calm()` | a collapse counted; a teammate's hand (nothing under 20); the countdown off, quietly |
| `needs_run(gh)`, `needs_watch(dt)` | the drain over `gh` game hours, and the countdown over `dt` real seconds (the system's tick runs both) |
| `needs_facts() -> Queue<NeedFact>` | `{ what, need }`: `NEEDS_CRITICAL`, `NEEDS_RESTORED`, `NEEDS_COLLAPSED` |
| `needs_system() -> System` | `"needs"`, `PH_SIMULATE`: reset, tick, and its save section (`needs_save`, `needs_load`: the four bars and the collapses) |

## Tests

```bash
ludic test packages/ludic.needs
```
