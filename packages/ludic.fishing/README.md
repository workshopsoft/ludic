# ludic.fishing

One angler's line: a cast into water deep enough, the wait for a bite (bait halves it), the strike,
the reel's fight - a marker sweeping a bar and a green band to press in, a Gentle ring of one
press, a legend that runs and takes line back - and the landing, with the species, length and
weight from data. Uses [`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.fishing"
```

The package never draws, never speaks and never touches a pack. It reports what happened as facts
(`fishing_facts()`), and the game takes the bait, puts the fish in the pack, shows it and says the
line. Its dice are its own `Rng`.

## The species

`FishSpecies` is an `open registry` the game fills, `FISH_<KEY>` in the order written:

```ludic
def FishSpecies cutthroat { weight: 0.45 }
def FishSpecies brook { weight: 0.25, cm_min: 20, cm_spread: 10 }
def FishSpecies old_maroon { legend: true, cm_min: 70, cm_spread: 25, skill_cm: 0.0, need: 5, runs: 2, fight: 30.0, speed: 1.3, speed_per_hit: 0.22, closes: 0.12 }
```

| field | |
| --- | --- |
| `weight` | how often it takes, among the everyday ones |
| `cm_min`, `cm_spread`, `skill_cm` | length: `cm_min` + up to `cm_spread`, + `skill_cm` per point of skill |
| `kg_k` | weight is `kg_k x cm^3` (a trout by default) |
| `legend`, `chance`, `chance_deep` | takes only a lure, at `chance` in the shallows and `chance_deep` past the deep line or afloat (+ skill) |
| `need`, `runs`, `fight` | crossings to land it, runs it makes, seconds before the line goes slack |
| `speed`, `speed_per_hit`, `closes`, `floor` | the marker's sweep, and a window that narrows with each crossing won (at every rung) |

## The port

```ludic
export port FishingWorld {
  depth: fn(float, float) -> float     # metres of water at a point
  afloat: fn() -> bool                 # in a boat (unbound: no)
  has_bait: fn() -> bool               # (unbound: no)
  has_lure: fn() -> bool               # (unbound: no)
  skill: fn() -> float                 # gear or hands (unbound: 0)
  bite_mult: fn() -> float             # the wait, x (unbound: 1)
  window: fn(int) -> float             # the green's half width for a species (unbound: 0.12)
  level: fn() -> int                   # FISHING_RELAXED / _STANDARD / _HARD / _GENTLE (unbound: relaxed)
}
```

## API

| | |
| --- | --- |
| `fishing_config(min_depth, deep, seed)` | 0.15 m to cast, 2.5 m is deep, the line's seed |
| `fishing_cast(x, z) -> int` | `FISHING_CAST_OK`, `FISHING_NOT_WATER`, `FISHING_BUSY` |
| `fishing_press()` | the one button: waiting it reels in, on a bite it strikes, on a fish it reels |
| `fishing_run(dt)`, `fishing_stop()`, `fishing_set_wait(secs)` | real seconds of line; put away; the bite in exactly `secs` |
| `fishing_state()` (`FISHING_OFF`, `_WAIT`, `_BITE_ON`, `_REEL`), `fishing_active()`, `fishing_species()`, `fishing_cm()`, `fishing_line_x()`, `fishing_line_z()`, `fishing_baited()`, `fishing_lured()` | the line |
| `fishing_marker()`, `fishing_window()`, `fishing_window_lo()`, `fishing_window_hi()`, `fishing_hits()`, `fishing_need()`, `fishing_running()`, `fishing_gentle()`, `fishing_ring()` | the fight, for a HUD |
| `fishing_caught()`, `fishing_biggest()`, `fishing_legend_caught()`, `fishing_record_set(n, cm, legend)` | the record |
| `fishing_weight_of(species, cm)`, `fishing_legend()`, `fishing_water_at(x, z)` | questions |
| `fishing_facts() -> Queue<FishingFact>` | `{ what, species, cm, kg, hits, need, bait, lure, x, z }`: `FISHING_CAST`, `_BAIT_USED`, `_BITE`, `_MISSED`, `_HOOKED`, `_GOOD`, `_CHECKED`, `_TURNED`, `_RUNS`, `_TIRED`, `_REELED_IN`, `_CAUGHT`, `_LINE_SNAPPED`, `_SLACK` |
| `fishing_reset()`, `fishing_system() -> System` | `"fishing"`, `PH_SIMULATE`: its tick, and the record in its save section (a line in the water is not saved) |

## Tests

```bash
ludic test packages/ludic.fishing
```
