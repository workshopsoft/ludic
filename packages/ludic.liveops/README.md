# ludic.liveops

What a live game does around its players: a **freemode event** now and then on a schedule the session's
seed decides, **modifiers** that make a weekend better (double XP and money, discounts on a shop category,
featured content), a **season** to climb in tiers, and **daily and weekly objectives** that come round. The
events, modifiers, seasons and objectives are rows a game writes in a `.lres`; the clock, the players and
the network are ports; what happened and what the game owes are facts. Uses
[`ludic.base`](../ludic.base/README.md) and nothing else. Nothing in it names a game, a mode or a shop.

```ludic
import "ludic.liveops"
```

**Host-authoritative.** Only the host (the `is_host` port) runs the schedule, reports objective progress,
adds season XP and claims rewards; those verbs answer false or 0 elsewhere. A client takes the event's state
from the host (`liveops_event_snapshot` / `liveops_event_adopt`, which makes the same facts). The modifiers,
seasons and the day's objectives follow the UTC clock everywhere, and the objectives are drawn from the seed and
the day's number, so every machine draws the same ones.

## The data

| Registry (prefix) | Record | What a row is |
| --- | --- | --- |
| `LiveSettings` (`LSET`) | `LiveSetting` | the schedule's numbers (the first row): the gap between events (`event_gap_min`..`max`), the warning (`event_announce`), the `retry` when nothing can run, how many `daily_count` / `weekly_count` objectives, the UTC `reset_hour`, the day a week starts (`week_starts`), the most a stack of bonuses may add up to (`max_bonus`, percent), how often remote rows are asked again |
| `FreemodeEvents` (`FEVT`) | `FreemodeEvent` | an event: `kind` (the game's word), `min_players`, `max_players`, `duration`, `area` or `areas` (one is drawn among the free ones), `cooldown`, `weight` scaled by `hours` (24 percents, the UTC hour) and `days` (7 percents, Monday first), its own `announce`, and rewards (`reward_money`, `reward_xp`, `reward_key`) |
| `LiveModifiers` (`LMOD`) | `LiveModifier` | `kind` `xp`, `money`, `discount` or `featured`; `target` (an activity, a shop category, a slot; `*` every one); `percent` (200: double; a discount's share off); `starts` and `ends` (UTC: `"2026-10-01"` or `"2026-10-01T18:30"`, empty for no limit); a rotation (`rot_days`, `rot_slots`, `rot_slot`: on when the day number divided by `rot_days`, modulo `rot_slots`, is `rot_slot`); `featured` the game's key |
| `Seasons` (`SEAS`) | `Season` | `starts`, `ends`, and `tiers`: each `xp` more than the one before, and a reward in the free track (`kind`, `key`, `amount`) and in the premium one (`premium_kind`, `premium_key`, `premium_amount`) |
| `LiveObjectives` (`LOBJ`) | `LiveObjective` | `period` (`daily` or `weekly`), `kind` (what the game reports), `need`, `weight`, and the reward (`reward_kind`, `reward_key`, `reward_amount`) |

```
sprint { kind: "sprint", min_players: 2, duration: 300, areas: ["north", "harbour"], cooldown: 1800, weight: 10, reward_money: 500 }
night_run { kind: "night_run", duration: 600, weight: 20, hours: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 100, 100, 100] }
double_weekend { kind: "xp", percent: 200, starts: "2026-10-03", ends: "2026-10-05" }
```

A date that is not one (`"soon"`) makes its row never live rather than always live. Dates are UTC: a modifier
ends at its `ends` minute exactly.

## The ports

```ludic
export port LiveWorld {
  is_host: fn() -> bool             # unbound: yes
  players: fn() -> int              # how many are in the session now (unbound: 1)
  utc_day: fn() -> int              # whole days since 1970-01-01 (unbound: the machine's UTC clock)
  utc_minute: fn() -> int           # the minute of that day, 0 to 1439
  area_free: fn(string) -> bool     # may an event take this area? (unbound: every one)
  has_premium: fn(int) -> bool      # the season's premium track (unbound: nobody)
  seed: fn() -> int                 # the session's seed (unbound: 1)
}
export port LiveRemote {            # the launcher's shape: a request is an int, poll is -1 pending, 0 failed, 1 ok
  get: fn() -> int                  # start a request, -1 for nothing to ask (unbound)
  poll: fn(int) -> int
  text: fn(int) -> string
  free: fn(int) -> void
}
```

**Remote rows.** A body is JSON: `{"modifiers": [...]}` or a list, each `{ "key", "kind", "target",
"percent", "starts", "ends", "rot_days", "rot_slots", "rot_slot", "featured" }`. `liveops_tick` asks
`LiveRemote` on its first tick and every `remote_refresh` seconds; `liveops_remote_load(text)` takes a body
the game fetched itself. A body that is not one changes nothing. The last good body is saved, so the last known
offers hold while the network is away. Remote rows come after the compiled ones in `liveops_mod_*`.

## The schedule

`Idle` until the next event's turn, `Announced` for its warning, `Running` for its duration (a `machine`
over the phase); then quiet for a gap drawn between the settings' least and most. At its turn the next event is
drawn by weight from those that may run now: enough (and not too many) players, off its cooldown, an area
free. None can: ask again after `retry`. Announced with too few players by the start: cancelled. The dice are
the session's seed, so the same seed and the same world answers give the same events.

## Bonuses

`liveops_xp_mult(activity)` and `liveops_money_mult(activity)` **add**: two double-XP weekends stacked are
triple, not quadruple, and the total stops at `max_bonus` percent. `liveops_discount(category)` is the best
one single discount, not their sum. Bind the multiplier to progression's port without either knowing the other:
`bind ProgressionWorld { xp_mult: fn live_xp }`.

## Facts

`liveops_facts(st)` is a `Queue<LiveFact>` (`what`, `player`, `idx`, `from`, `to`, `amount`, `kind`, `key`, `area`):

| `what` | when |
| --- | --- |
| `LIVE_EVENT_ANNOUNCED`, `_STARTED`, `_ENDED`, `_CANCELLED` | an event's phases (`idx`, `kind`, `area`; `amount` the seconds to go, or the duration) |
| `LIVE_OBJECTIVE_DONE` | a player completed an objective (`player`, `idx`, `from` 0 daily / 1 weekly, `to` the slot) |
| `LIVE_OBJECTIVES_ROLLED` | a new day or week drew again (`from`) |
| `LIVE_SEASON_STARTED`, `_ENDED`, `_TIER` | a season began or ended (`idx`); a player reached a tier (`player`, `idx`, `to`) |
| `LIVE_REWARD` | **the game pays this**: `player`, `kind`, `key`, `amount`, `from` (`LIVE_FROM_EVENT`, `_OBJECTIVE`, `_SEASON`). Liveops never pays: the game routes it to its wallet, its inventory, its progression |
| `LIVE_MODIFIERS_CHANGED` | the set of live modifiers moved: one began, one ended, rows arrived |

## API

| | |
| --- | --- |
| `liveops_tick(t)`, `liveops_reset()`, `liveops_system() -> System` | once a frame; `"liveops"`, `PH_SIMULATE` with its save section (`liveops_save`, `liveops_load`) |
| `liveops_event_phase()`, `_current()`, `_area()`, `_id()`, `_running()`, `_left()` | the event now; `LIVE_PHASE_IDLE`, `_ANNOUNCED`, `_RUNNING`; seconds to the start, the end, or the next turn |
| `liveops_event_start(e)`, `liveops_event_end()`, `liveops_event_reward(player)` | start one now (host; its warning first); end it; pay a player its rewards once |
| `liveops_event_snapshot() -> []int`, `liveops_event_adopt(xs, area)` | what the host sends a client; what a client does with it |
| `liveops_xp_mult(activity)`, `liveops_money_mult(activity)`, `liveops_discount(category)`, `liveops_price(category, price)`, `liveops_featured(slot)` | what the live modifiers do now |
| `liveops_mod_count()`, `_mod_key(i)`, `_mod_active(i)`, `_mod_remote(i)`, `liveops_remote_load(text)`, `liveops_remote_count()` | the modifiers, rows then remote |
| `liveops_season()`, `_season_days_left()`, `_tier_count(s)`, `_tier_xp(s, tier)`, `_tier_for(s, xp)` | the season the date is in |
| `liveops_season_add_xp(player, n)`, `_season_xp`, `_season_tier`, `liveops_season_claim(player, tier, premium)`, `_season_claimed` | a player's climb |
| `liveops_objective_count(weekly)`, `_objective(weekly, slot)`, `_objective_progress`, `_objective_state`, `liveops_report(player, kind, amount)`, `liveops_objective_claim(player, weekly, slot)` | the objectives; state 0 going, 1 done, 2 claimed |
| `liveops_date_minutes(text)`, `liveops_days_from_civil(y, m, d)`, `liveops_weekday(day)`, `liveops_forget(player)` | dates in integers |

The save holds what is left of each timer (the session's clock starts at 0 each run), the cooldowns, each
player's season and this day's and week's progress, and the last remote body.

## Tests

```bash
ludic test packages/ludic.liveops
```

A fake world (players, UTC day and minute, free areas, premium, seed, a remote body): the schedule and its
cooldown, retry, players and areas; hours and days scaling the odds; the same seed, the same events; the
host only; rewards once per player; stacked and capped bonuses, discounts, rotation, a change as a fact,
remote rows and their refresh; seasons, tiers and claims; objectives drawn from the seed, reported, claimed,
rolled by day and week; and the save.
