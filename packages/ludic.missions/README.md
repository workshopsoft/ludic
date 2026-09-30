# ludic.missions

Jobs, contact missions, heists, races and adversary modes as **data graphs**. A mission is rows of
nodes (objectives) and edges (what happens when one ends); a run is one instance of it for a lobby or
a team, with the objective state, the markers as facts, checkpoints and retries, roles, teams and cuts;
a player-made race or mode is the same rows. Host-authoritative: the host decides and sends snapshots,
a guest's verbs are asks. Uses [`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.missions"
```

The package knows what a mission *is*, never what it is *about*. A node's `target` is the game's
word (a place, an item, an enemy group, a minigame); the game reports what its players did
(`mission_report`), answers where they stand and whether the law is after them (`MissionsWorld`), and
pays what a mission earns (`MissionsPay`). Nothing here spawns, draws or words anything: the game
reads the facts and does.

## The data

All tables are `open`, `@AppendOnly @ByKey` registries (`def Missions from "missions.lres"`, or `def`
from any module). A row names another by its **key**, never by its place, so a studio edits a mission
as two plain tables and a player's creation, which has no compiled constants, is the same records.

| registry | a row is | notes |
| --- | --- | --- |
| `Contacts` (`CONTACT_*`) | a person who gives missions | `title`, `intro`, `min_rank` |
| `Missions` (`MIS_*`) | a mission: kind (`MSK_JOB`, `_CONTACT`, `_SETUP`, `_FINALE`, `_RACE`, `_ADVERSARY`, `_CUSTOM`), `contact`, `heist`, `min_players`/`max_players`, `teams`, `time_limit`, `start` (a node's key, else the first), the pot (`money`, `xp`, `item`), `fee`, `replay` (`MSREP_ALWAYS` / `_ONCE` / `_DAILY`), `cooldown`, `needs` (missions to have won), `min_rank`, `retries`, `join_in_progress`, `wipe`, `share` (`MSSHARE_EQUAL` / `_CUTS` / `_SCORE` / `_PLACE`), `payout` (percent by place), `leader_cut` | |
| `MissionSteps` (`MSTEP_*`) | a node: `mission`, `kind` (`MSN_*`), `target`, `x` `y` `z` `radius`, `count`, `seconds`, `role`, `who` (`MSW_ANY` / `_ALL`), `join`, `checkpoint`, `hidden`, `blip`, `arg`, `gates`, and `ex` `ey` (where an editor draws it) | |
| `MissionEdges` (`MEDGE_*`) | an edge: `mission`, `from`, `to`, `on` (`"done"`, `"fail"`, `"timeout"`, or a choice's key), `cond`, `par` | |
| `MissionRoles` (`MROLE_*`) | a part: `mission`, `least`, `most`, `team`, `cut` (a weight), `leader` | |
| `HeistChains` (`HEIST_*`) | a heist: `finale`, `contact`, crew size, `crew_cut_floor` | |
| `HeistPreps` (`HPREP_*`) | a planning-board item: `heist`, `mission` (the setup), `group`, `modifier`, `cost`, `optional`, `after` | |
| `CreationKinds` (`CKIND_*`) | what a player may build, the node it compiles to, its limits, what it pays | |

### The node kinds

`MSN_GOTO` (be at `x, z` within `radius`, or be reported at the place `target`; `who: MSW_ALL` needs
every live member), `MSN_COLLECT`, `MSN_DELIVER`, `MSN_ELIMINATE` (`count` of `target`, pooled across the
team), `MSN_DEFEND` (keep `target` for `seconds`; `MRP_LOST` fails it), `MSN_MINIGAME` (a hack or a
lockpick: the node asks `target` of the eligible player as a fact, the game reports the result),
`MSN_SURVIVE`, `MSN_ESCAPE` (nobody eligible is wanted), `MSN_RACE` (the gates in order, `count` laps,
each racer's place), `MSN_WAIT_TEAM` (everyone, or `count`, is ready), `MSN_CHOICE` (the edge whose `on`
is the chosen key), `MSN_SCORE` (a team reaches `count`; at the clock the best team leads), `MSN_WAIT`,
`MSN_SIGNAL` (the game says `target` is so: anything the list lacks), `MSN_DO` (the game is asked to do
`target`: spawn, cut-scene; done at once), `MSN_PASS`, `MSN_FAIL`. `seconds` is a limit (a timeout ends
the node with outcome `"timeout"`) except where it is a duration (`DEFEND`, `SURVIVE`, `WAIT`: done when it
runs out) or ends a race or a competitive score (done; the best leads). A node naming a `role` counts
only that role's players.

### How the graph runs

A node opens when it has had `join` arrivals. When it ends with an outcome, the edges that leave it on
that outcome are tried in table order: the first whose `cond` holds is taken, and every `par` edge is
taken beside it (a fork; a node with `join: 2` is the join). `cond` is `flag:<key>` (a modifier a heist's
prep set), `!flag:<key>`, or any other word, which `MissionsWorld.check` answers. A node with no edge for
`"done"` wins the mission; one with none for `"fail"` or `"timeout"` loses it. A loop of more than 64
instant nodes loses the run (`MSE_GRAPH`). `mission_problems` is the lint a studio shows beside the graph
(`error:` stops a run, `warning:` only looks wrong): unknown nodes, no gates in a race, a node that lasts no
time, a choice with fewer than two options, a mission that can never be won, unreachable nodes.

A `checkpoint` node snapshots the run as it opens; `mission_retry` restores it (or restarts at `start`
without one) while the mission has `retries` left, members back on their feet and the mission's clock
starting over.

## Ports

```ludic
export port MissionsWorld {
  host: fn() -> bool             # this machine decides (true)
  x, z: fn(int) -> float         # (who) where a player is (0)
  alive: fn(int) -> bool         # (true)
  wanted: fn(int) -> int         # (who) the heat: 0 is clear
  check: fn(string, int) -> bool # (cond, run) an edge's condition that is not a flag (true)
  rank: fn(int) -> int           # for min_rank (0)
  day: fn() -> int               # for daily replays (1)
  seed: fn() -> int              # entropy for a run's payment keys: give it a real one
}
export port MissionsPay {
  charge: fn(int, int, string) -> bool           # (who, money, key) a fee: false when it cannot be paid
  money: fn(int, int, string) -> void            # (who, money, key)
  xp: fn(int, int, string) -> void
  item: fn(int, string, int, string) -> void     # (who, item, count, key)
}
```

Every payment carries a **key** no other payment shares (`<mission>:<run's nonce>:<who>:money`), so a
persistence service ([`ludic.persist`](../ludic.persist/README.md)) can take it as an idempotency key and a
resent payment pays once.

## Verbs

| | |
| --- | --- |
| `missions_init`, `missions_reset`, `mission_find(key)`, `mission_nodes`, `mission_node_find`, `mission_problems`, `missions_of_contact` | the plans |
| `mission_reason(plan, members)`, `mission_player_reason(who, plan)`, `mission_cooldown_left`, `mission_done_count`, `mission_best_time`, `mission_why` | what stops a group or a player (`MSG_*`) |
| `mission_start(plan, group, members)`, `mission_begin(run)`, `mission_launch` (both), `mission_join`, `mission_leave`, `mission_prefer_role`, `mission_retry`, `mission_abandon`, `mission_fail`, `mission_close` | a run's life; `group` is the lobby or team the game means |
| `mission_report(run, who, what, target, n)` | `MRP_ARRIVED`, `_COLLECT`, `_DELIVER`, `_KILL`, `_LOST`, `_HACKED`, `_READY`, `_CHOICE`, `_SIGNAL`, `_SCORE`, `_DIED`, `_RESPAWNED`, `_GATE`, `_FAIL` |
| `mission_tick(dt)` | positions, gates, the heat, timers; the system calls it in `PH_SIMULATE` |
| `mission_phase`, `mission_active`, `mission_node_state`, `mission_node_have`, `mission_time`, `mission_time_left`, `mission_who`, `mission_team_of`, `mission_team_score`, `mission_player_score`, `mission_role_key`, `mission_leader`, `mission_alive`, `mission_flag` / `mission_set_flag` | a run as it stands |
| `mission_place`, `mission_finish_time`, `mission_lap`, `mission_gate` | a race |
| `mission_markers(run, who)` | what to point at for one player (a race shows each racer their own next gate) |
| `mission_payout_preview(run)` | what each slot would be paid if the run were won now |
| `heist_begin`, `heist_preps`, `heist_prep_state`, `heist_start_prep`, `heist_ready`, `heist_set_cut`, `heist_cuts_default`, `heist_cuts_ok`, `heist_start_finale`, `heist_phase`, `heist_has_flag` | a heist and its planning board |
| `creation_new`, `creation_add_gate`, `creation_set_rule`, `creation_problems`, `creation_compile`, `creation_to_val` / `_from_val`, `creation_get`, `creation_remove`, `creation_played` | player-made missions |
| `mission_snapshot(run)`, `mission_apply(val)`, `mission_rev(run)` | host authority |
| `missions_progress_val(who)` / `missions_progress_load(who, val)`, `missions_save` / `missions_load`, `missions_system()` | what players have won |

### Roles, teams and pay

Roles are given when a run begins (`mission_begin`): each role gets its `least` first (those who asked for it
with `mission_prefer_role`, then the others in order), then the rest by preference up to each `most`; a
role marked `leader` makes its holder the leader. A role's `team` is the member's team; a mission with no
roles deals teams round-robin. The pot (`money`) is paid when the mission is won: `leader_cut` percent off
the top to the leader, the rest by `share` (even, by each member's cut, by score, or by place through
`payout`), the rounding to the leader so the pot is paid out to the last coin. `xp` and `item` go to every
member. A player who left before the end is paid nothing.

### Heists

A heist is a `HeistChains` row (finale, crew size) and its `HeistPreps`: setups on a planning board, each a
mission of its own (`kind: MSK_SETUP`) that the leader starts with some or all of the crew and pays `cost`
for. A prep's state is `HP_LOCKED` (its `after` is not done), `HP_AVAILABLE`, `HP_ACTIVE`, `HP_DONE` or
`HP_DECLINED` (another of its `group` is done: one approach of three is enough). `heist_ready` holds when
every non-optional prep is done. Finishing a prep sets its `modifier` as a flag on the finale, where an edge's
`cond: "flag:<key>"` takes a shortcut. The leader sets the crew's cuts on the board (`heist_set_cut`, each at
least `crew_cut_floor`, together 100), and `heist_start_finale` refuses until the cuts are right.

### Player-made missions

A `Creation` (id, author, kind, title, gates, laps, seconds, score, rules, tags...) is what a player fills
in; its `CreationKinds` row says which node it becomes and how much it may hold. `creation_problems` names
every limit it breaks, line by line; `creation_compile` makes the plan (a waiting room, the kind's node, the
win) and the same machinery runs it. A creation is a value (`creation_to_val`, numbers as thousandths so it
reads back exactly) and `creation_from_val` bounds whatever it is given, so it is safe to take one from the
wire. What finishing pays is the kind's (the game's economy), never the creator's.

## Host authority

Every verb that changes a run is the host's (`MissionsWorld.host()`); on a guest it pushes an `MSF_ASK` fact
(`ask`: `MSA_REPORT`, `_JOIN`, `_LEAVE`, `_RETRY`, `_ABANDON`, `_ROLE`) for the game to send to the host,
and returns false. The host sends `mission_snapshot(run)` when `mission_rev(run)` moves; a guest calls
`mission_apply`, which makes or updates a mirror, says `MSF_NODE`, `_NODE_DONE`, `_PASSED`... for what
changed, and ignores a snapshot older than the one it has. The mirror answers every query, runs the clocks for
drawing, and decides nothing. A run that is a creation's carries the creation in its snapshot, so a guest that
has never seen it can compile it.

## Facts

`missions_facts()` is a `Queue<MissionFact>` (`what`, `run`, `plan`, `node`, `who`, `team`, `have`, `need`,
`n`, `reason`, `x`, `z`, `radius`, `text`, `key`): `MSF_STARTED`, `_BEGAN`, `_JOINED`, `_LEFT`, `_ROLE`, `_NODE`,
`_NODE_DONE`, `_NODE_FAILED`, `_PROGRESS`, `_MARKER_ON` / `_MARKER_OFF` (where to point, and for whom),
`_MINIGAME` (start `text` for `who`), `_DO`, `_CHOICE` (the options), `_CHECKPOINT`, `_RETRY`, `_PASSED`,
`_FAILED` (`reason`: `MSE_*`), `_ENDED`, `_PAY_MONEY` / `_PAY_XP` / `_PAY_ITEM` (with the payment's `key`),
`_FEE`, `_TEAM_SCORE`, `_PLACE`, `_PROGRESS_SAVED` (a player's record changed: save it), `_HEIST_*`, `_ASK`,
`_CREATION`, `_FLAG`.

## Save

Section `missions`, version 1: the missions clock and each player's record of what they have won (count,
tries, when, the day, the fastest time). Runs are a session's and are not saved. A game that keeps a player's
record elsewhere uses `missions_progress_val` / `_load`.

## Tests

```bash
ludic test packages/ludic.missions
```

On a fixture of missions a game might write (a courier job with a checkpoint, a convoy, a fork and its join,
an adversary match, a race, a bank heist with roles, a choice and a minigame): the plans and their lint, what
stops a group, every node kind, the clocks, a lost run retried from its checkpoint, markers, roles by
preference, the planning board and its cuts, the pot split exactly, a creation judged, compiled and run, a
guest's asks, a snapshot through text, a late snapshot, and the save.
