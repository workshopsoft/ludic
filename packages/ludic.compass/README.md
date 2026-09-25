# ludic.compass

Bearing markers on a strip: where things are from where you stand. Each frame the package asks
every provider the game registered, keeps the marks the viewer's compass is good enough to show,
sorts them by priority and culls them to a cap, and answers each one's bearing and distance - for a
strip across the top of the screen, a radar in a corner, a map, or a guide's arrow. Uses
[`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.compass"
```

The package never draws and never names a picture. A mark's `icon` and `colour` are the game's
keys (an index into its icon sheet and its palette), and its `label` is the game's words.

## A mark

| | |
| --- | --- |
| `x`, `z` | where it is in the world |
| `icon`, `colour` | the game's keys for its picture and its colour |
| `tier` | the least compass that shows it: the viewer's `CompassWorld.tier()` below it, the mark is dropped |
| `prio` | `COMPASS_TRACKED` (the objective: its distance is shown, and it stays at the strip's edge when off it), `COMPASS_NOTE` (one the player asked for), `COMPASS_PLAIN` |
| `label` | its name |

## Providers

A provider is a function that calls `compass_mark` for each thing it knows about. The game
registers them in the open registry, and `compass_gather()` asks them in the registry's order:

```ludic
def CompassProviders places { gather: fn cp_places }
def CompassProviders story { gather: fn story_marks }
```

Then the marks are sorted - tracked first, then notes, then the rest, each band in the order the
providers gave them - and culled to `compass_config(cap)`. A viewer with tier 0 gathers nothing.

A **capture** lets something else hear where the providers point without touching the frame's
list, whatever the tier (a guide that points at the objective before a compass is bought):

```ludic
compass_capture_begin()
story_marks()
let marks = compass_capture_end()
```

## The port

```ludic
export port CompassWorld {       # every member has a default: at the origin facing -z, every tier
  x: fn() -> float
  z: fn() -> float
  yaw: fn() -> float             # radians; 0 faces -z, and +yaw turns toward -x
  tier: fn() -> int              # the compass carried; 0 none
}
```

## API

| | |
| --- | --- |
| `compass_config(cap)` | how many marks a frame keeps |
| `compass_gather()` | once a frame: begin, every provider, end |
| `compass_begin()`, `compass_mark(x, z, icon, colour, tier, prio, label)`, `compass_end()` | the frame by hand (a test, one provider asked alone) |
| `compass_capture_begin()`, `compass_capture_end() -> []CompassMark`, `compass_capturing()` | the providers heard by someone else |
| `compass_count()`, `compass_at(i) -> CompassMark`, `compass_tracked()` | the frame's marks; the first tracked one or -1 |
| `compass_bearing(i)`, `compass_dist(i)`, `compass_bearing_to(x, z)`, `compass_dist_to(x, z)` | from the viewer: a bearing in -pi .. pi off its facing, a distance in metres |
| `compass_heading(dx, dz)`, `compass_rel(heading)`, `compass_wrap(a)`, `compass_strip_t(bearing, half)` | the arithmetic: a world heading, as the strip sees it, wrapped, and across a strip showing `half` either side (-1 .. 1 on it) |
| `compass_octant(dx, dz)` | which of eight points an offset lies toward, 0 at heading 0 and going toward -x (N, NW, W ...) |
| `compass_config_radar(ranges, from_tier)` | the radar's range per compass tier (0 none; past the table the last) and the least mark tier it shows (the tracked mark always) |
| `compass_radar_on()`, `compass_radar_range()`, `compass_radar_has(i)`, `compass_radar_x(i)`, `compass_radar_y(i)` | the radar: carried, how far, whether a mark is a blip, and where on a unit disc (x right, y down, ahead is up) |

There is no save: the marks are the providers' state, asked again every frame.

## Tests

```bash
ludic test packages/ludic.compass
```

A viewer and two providers: the order and the bands, the tier gate and no compass, the cap,
bearings and distances as the viewer turns and moves, a capture, the radar's tiers and blips, and
the eight points.
