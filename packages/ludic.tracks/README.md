# ludic.tracks

What animals leave on the ground: prints in a ring per kind, each remembering who left it, which
way it went and when, so a print can be read up close ("fresh elk tracks, heading north-west").
Other sign - droppings, a legend's mark - is told to the package so every reading goes through
one queue and one count. Uses [`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.tracks"
```

The package is the logic only. A kind is the game's number (a hoof, a paw); the game draws the
prints through the `placed` hook, which hands it the kind and the ring index, and the ring index
is stable until the ring comes round and writes over it.

A print is read ONCE: reading it again is still a `TrackRead` fact (the game says what it is
again) but `first` is false and it counts nothing, so pressing a key over one print is not as
good as walking a trail.

## The port

```ludic
export port TracksWorld {        # every member has a default, so any may be left out
  now: fn() -> float              # game hours counted from the start of the trip (unbound: 0)
  skill: fn() -> int              # the reader's tier; at tracks_config_reading's name_at it names the animal
  bearing: fn(float) -> string    # a yaw in words, "" for none (a reader with no compass)
  placed: fn(int, int) -> void    # a print was put down at (kind, ring index): draw it
}
```

The game fills it once, where it is put together - a declaration, not a call:

```ludic
bind TracksWorld { now: fn rt_trip_hours, skill: fn track_skill, bearing: fn track_bearing, placed: fn track_mark_placed }
```

## API

| | |
| --- | --- |
| `bind TracksWorld { ... }`, `tracks_config(kinds, cap)`, `tracks_config_reading(name_at, fresh, recent)` | the port; how many kinds and how many prints of each; the skill that names the animal and the ages (hours) under which a print is fresh or recent |
| `tracks_leave(kind, x, z, yaw, sp, legend) -> int`, `tracks_leave_at(..., made)` | a print, now or at another machine's time; returns its ring index |
| `tracks_clear()` | the ground forgets every print (a new world); the reader keeps what it learned |
| `tracks_nearest(x, z, r) -> int` | the nearest print within `r`, as a slot (`kind * cap + index`), or -1 |
| `tracks_read(slot)` | read a print: a fact every time, a count and the last bearing |
| `tracks_note(sp, source, legend, yaw, first)` | a sign that is not a print (`TRACK_SIGN`, `TRACK_SCAT`); the caller knows whether it is its first reading |
| `tracks_note_bearing(yaw)`, `tracks_set_read_count(n)` | the way the last thing went (a bed); the count outright (a test, an old save) |
| `tracks_kinds()`, `tracks_cap()`, `tracks_count(kind)`, `tracks_slot(kind, i)` | the rings |
| `tracks_x`, `tracks_z`, `tracks_yaw`, `tracks_sp`, `tracks_legend`, `tracks_made`, `tracks_age`, `tracks_was_read` (slot) | a print |
| `tracks_fresh_of(age)` | `TRACK_FRESH`, `TRACK_RECENT` or `TRACK_OLD` |
| `tracks_read_count()`, `tracks_last_yaw()`, `tracks_has_bearing()` | what the reader has learned |
| `tracks_reads() -> Queue<TrackRead>` | the facts: `{ sp, source, kind, legend, age, fresh, yaw, named, bearing, first }` |
| `tracks_system() -> System` | `"tracks"`, `PH_SIMULATE`: reset, and its save section (the count and the last bearing; the prints are the ground's and are not saved) |

## Tests

```bash
ludic build packages/ludic.tracks/tests/tracks_test.ludic --headless -o /tmp/tracks_test && /tmp/tracks_test
```
