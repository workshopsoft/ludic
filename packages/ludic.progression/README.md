# ludic.progression

What a player has become: XP on **tracks** turned into levels by a **curve**, what each level
**unlocks** (free, or bought), **skills** that grow by being used and export their effect as stat
modifiers, **roles** with a track of their own, and **prestige**. Nothing in it names a game: the curves,
tracks, roles, awards, unlocks and skills are rows a game writes in a `.lres`, and what the game's world
answers - the live multiplier on an activity, the money, who listens to stats - are ports. Uses
[`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.progression"
```

**Host-authoritative.** Only the machine the `is_host` port says is the host awards XP, trains skills,
sells unlocks, starts roles and prestiges (every such verb answers 0 or false elsewhere). A client takes
the host's word with `progression_apply` of a `progression_snapshot`, which is also what a save holds.
Every player is a number the game gives (0 is this machine's own in a single-player game); a row is made
the first time anything is said about a player.

## The data

Six registries, all `open` and `@ByKey`, filled with `def XpCurves from "data/progression.lres"` and the
like. The five the index order matters for (tables a save reads by position) are `@AppendOnly`.

| Registry (prefix) | Record | What a row is |
| --- | --- | --- |
| `XpCurves` (`XPCV`) | `XpCurve` | how much XP each level takes: a `thresholds` table (`[100, 250, 500]`: level 2 at 100, 3 at 250, 4 at 500, top 4), or a formula `base`, `per_level`, `max_level`: the total for level L is `base*(L-1) + per_level*(L-1)*(L-2)/2` |
| `ProgressionTracks` (`PRGT`) | `ProgressionTrack` | a track of XP: its `curve`, and `prestige` (at its top level, back to 1 for `prestige_xp_pct` percent more XP per prestige, up to `prestige_max` times) |
| `ProgressionRoles` (`PRGR`) | `ProgressionRole` | a role with a `track` of its own, begun at `min_level` of the general track for a `price`; it may add `stat_mod` to a `stat` while it is on |
| `XpAwards` (`XPAW`) | `XpAward` | what an activity (`key`, the game's word) is worth: `xp` times `mult` to a `track`, and `skill` used `skill_uses` times |
| `Unlocks` (`UNLK`) | `Unlock` | what a level opens: the game's `what` and `kind`, reached at `track` `level`, and optionally after another unlock (`requires`), in a `role`, at a `skill` level; a `price` above 0 offers it to be bought |
| `Skills` (`SKLL`) | `Skill` | a skill: `rate` points a use (less near the cap when `diminishing`), up to `cap`, `level_points` a level; its modifier runs from `mod_min` to `mod_max` on `stat` |

```
delivery { track: PRGT_RANK, xp: 50, skill: SKLL_DRIVING, skill_uses: 2 }
race_won { track: PRGT_RANK, xp: 120, mult: 1.5 }
```

The first track no role owns is the **general** track (what a role's `min_level` is asked of). A role's
track takes XP only while the player is in the role. An unlock is reached when every condition holds:
the track's level, the required unlock had, the role on, the skill level. Unlocks with no price open at
once (a chain of `requires` opens in one go); priced ones become **offered** and are bought with
`progression_buy_unlock`. A condition that lapses (the role ended) withdraws an offer, never takes back
what was had.

## The ports

```ludic
export port ProgressionWorld {
  is_host: fn() -> bool            # unbound: yes
  xp_mult: fn(string) -> float     # a live multiplier on an activity's XP (unbound: 1.0)
  spend: fn(int, int) -> bool      # (player, amount): money for an unlock or a role (unbound: always paid)
}
export port ProgressionOut {
  stat: fn(int, string, float) -> void     # (player, stat, total modifier): unbound, nobody listens
}
```

The live multiplier is how a live-operations event doubles XP without progression knowing one exists: the
game binds `xp_mult` to the answer of whatever runs events (`ludic.liveops`'s `liveops_xp_mult`).
`ProgressionOut.stat` is told a stat's new **total** (every skill that names it, and the role) whenever a
skill crosses a level or a role starts or ends; ask `progression_stat` for the exact figure now.

## Facts

`progression_facts(st)` is a `Queue<ProgFact>` (`what`, `player`, `track`, `idx`, `from`, `to`, `amount`,
`key`):

| `what` | when |
| --- | --- |
| `PROG_XP` | XP went in (`track`, `amount`) |
| `PROG_LEVEL_UP` | a track rose one level (`track`, `from`, `to`), one fact per level |
| `PROG_UNLOCKED` | an unlock opened (`idx`, `key` the row's `what`; `amount` is the price paid, if bought) |
| `PROG_OFFERED` | a priced unlock became available (`idx`, `key`) |
| `PROG_SKILL_UP` | a skill reached a new level (`idx`, `from`, `to`) |
| `PROG_PRESTIGE` | a track was prestiged (`track`, `to` the count) |
| `PROG_ROLE_START`, `PROG_ROLE_END` | a role began or ended (`idx`, `track`) |

## API

| | |
| --- | --- |
| `progression_award(player, activity) -> int`, `progression_award_at(player, award, times)`, `progression_award_worth(player, award)` | an activity happened: XP to its track (x its multiplier, the prestige share and the live multiplier), its skill used; how much went in. The worth is asked without paying |
| `progression_add_xp(player, track, n) -> int` | exactly `n` (the story's word), clamped at what the track holds |
| `progression_level`, `_xp`, `_xp_to_next`, `_fraction`, `_max_level`, `_at_max`, `_prestige_count` | a track's state for a player |
| `progression_curve_xp(curve, level)`, `progression_curve_level(curve, xp)`, `progression_curve_max(curve)`, `progression_track_cap(track)`, `progression_general_track()` | the curves |
| `progression_unlock_state(player, u)`, `progression_has`, `progression_allows(player, what)`, `progression_unlock_of(what)` | what is opened; `allows` is true for a key no unlock gates |
| `progression_buy_unlock(player, u) -> bool`, `progression_grant_unlock(player, u) -> bool` | pay for an offered one; open one outright |
| `progression_skill_use(player, skill, uses) -> int`, `_skill_points`, `_skill_level`, `_skill_mod`, `progression_stat(player, stat) -> float`, `progression_tell_all(player)` | skills and the modifiers they carry |
| `progression_role(player)`, `progression_role_can_start`, `progression_role_start`, `progression_role_end` | roles |
| `progression_can_prestige`, `progression_prestige(player, track) -> bool` | prestige |
| `progression_snapshot(player) -> []int`, `progression_apply(player, xs) -> bool` | a player's progress as ints, to send a client or to load |
| `progression_players()`, `progression_player_at(i)`, `progression_forget(player)` | who has a row |
| `progression_facts() -> Queue<ProgFact>` | the facts |
| `progression_reset()`, `progression_system() -> System` | `"progression"`, `PH_COMMIT`: reset, and its save section (`progression_save`, `progression_load`) |

The save is each player's snapshot (the counts lead, so a table that has grown since still reads back what
it had). A game saves the rows of players whose numbers are stable.

## Tests

```bash
ludic test packages/ludic.progression
```

A fake game with two curves, a role, awards from a `.lres`, priced and chained unlocks, two skills: levels
through both curve kinds, awards and the live multiplier, roles and their track, free/priced/chained/skill/
role unlocks, skill growth and the exported stat, prestige, host-only verbs and a client applying a
snapshot, and the save section.
