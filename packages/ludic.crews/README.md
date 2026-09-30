# ludic.crews

Gangs and crews: ranks with permissions, a crew bank, an emblem and colours, relations between crews (ally,
neutral, rival, at war) as rules, territories a map holds, influence earned from what players do (kills, time
spent there, jobs), decay and capture thresholds, turf wars as a `@Machine` (peace, contested, war, cooldown),
bounties and rivalries that harden by themselves. Uses [`ludic.base`](../ludic.base/README.md) and nothing else.
Nothing here names a rank, a district or a rival: they are rows.

```ludic
import "ludic.crews"
```

## The data

| Registry | Prefix | A row is |
| --- | --- | --- |
| `CrewRanks` | `CRR_` | a rank: `power` (higher outranks), `leader` (what a founder holds), `start` (what a joiner gets), the permissions `invite` `kick` `promote` `withdraw` `declare` `edit` `disband` `war`, `withdraw_limit` a game day, a `@Color` |
| `CrewRelations` | `CRL_` | how two crews stand: `start`, `contest` (may contest each other's turf), `war` (a turf war may be fought), `friendly_fire` (a kill between them is not a kill), `mutual` (needs the other's accept), `kill_pct` and `bounty_pct`, `hold_hours`, and `escalate_kills` / `escalate_to` (a rivalry that moves on by itself) |
| `CrewSettings` | `CRG_` | the numbers (the first row; none: the record's defaults): members, name length, founding cost, invite life, `influence_max`, `decay_min`, `kill_influence`, `victim_loss`, `presence_min`, `contest_at`, `capture_at`, `war_at`, `war_secs`, `defender_pct`, `cooldown_secs`, `income_secs`, bounty limits |
| `CrewSources` | `CRI_` | something a player can do that earns influence where it happens: `amount` for their crew, `loss` from the crew holding the place |
| `CrewEmblems` | `CRE_` | an emblem: `@Asset("png") texture`, `price` |
| `Territories` | (per map) | a territory: `@PerMap`, `maps/<map>/territories.lres` - a `disc` (`x` `z` `radius`), a `polygon` (`poly`: x, z pairs) or `cells` (`cell` metres, `cells`: cx, cz pairs), `value`, `income`, `capture_at` |

The registries are open, append-only and saved by key; `def` them in code or `def CrewRanks from "ranks.lres"`.

```
harbor   { name: "Harbor", district: "Docks", shape: "disc", x: 0.0, z: 0.0, radius: 50.0, value: 10, income: 100 }
old_town { shape: "polygon", poly: [100.0, 0.0, 200.0, 0.0, 200.0, 100.0, 100.0, 100.0], capture_at: 200.0 }
market   { shape: "cells", cell: 10.0, cells: [30, 30, 31, 30, 30, 31] }
```

## Ports

```ludic
export port CrewWorld {     # defaulted: this machine owns the world, nobody is anywhere
  authority: fn() -> bool
  players: fn() -> int;  player: fn(int) -> int      # who is there to count as present
  x: fn(int) -> float;  z: fn(int) -> float          # (who): where they stand
}
export port CrewWallet {    # defaulted: money is no object
  spend: fn(int, int) -> bool;  earn: fn(int, int) -> void
}
```

## Crews

`crew_create(who, name, tag, emblem, color_a, color_b)` checks the name (length within the settings, unique
without regard to case) and the founding cost, and makes the founder the `leader` rank. `crew_invite` (rank must
invite; an invite lasts `invite_secs`), `crew_join` (an invite, or an `open` crew), `crew_decline`, `crew_leave`
(a leader who is not alone hands the crew on first; one who is alone closes it), `crew_kick` and `crew_set_rank`
(the actor must hold the permission and outrank both the member and the rank given), `crew_transfer` (the
leader steps down to the highest other rank), `crew_set_open`, `crew_set_look`. `crew_deposit` / `crew_withdraw`
move money between the wallet and the bank; a rank's `withdraw_limit` holds a game day (the tick's hours reset
it). `crew_disband` pays the bank to whoever closes the crew and clears its members, invites, relations and
influence, and its territories go unowned.

## Relations and rivalries

A pair of crews stands at the `CrewRelations` row marked `start` until `crew_propose(who, other_crew, relation)` (a
rank with `declare`): a relation that is not `mutual` takes hold at once, a mutual one waits for `crew_accept` or
`crew_reject`; a relation keeps for its `hold_hours` of game time. Kills between two crews count on the pair,
and a relation with `escalate_kills` moves the pair to `escalate_to` when they add up (rival to war), with a `RELATION`
fact marked automatic. Relations decide the rest: who may contest a territory (`contest`), whether a war may be
fought (`war`), whether a kill is a kill (`friendly_fire`), and what a kill is worth in influence and in bounty.

## Influence

What happens becomes influence, per crew per territory, a float from 0 to `influence_max`:

- `crew_killed(terr, killer, victim, x, z)`: the killer's crew gains `kill_influence` (by the relation's `kill_pct`)
  where it happened, the victim's crew loses `victim_loss`, a war there scores for the side, the pair's kills count,
  and a bounty on the victim is paid to the killer (by `bounty_pct`). Killing your own crew, or an ally, is a
  `FRIENDLY_FIRE` fact and nothing else.
- `crew_report(terr, who, source, x, z, units)`: a `CrewSources` row (a job done, a delivery), where `who` is.
- Presence: each tick the players `CrewWorld` lists standing in a territory earn their crew `presence_min` a minute.
- `crew_add_influence` by hand.

Influence decays (`decay_min` a minute) and a fact (`LEAD`) says when a different crew leads a territory.

## Turf war: a `@Machine`

Each territory of a loaded map has a turf (`crew_turf_sync`, which the tick does when the map changes) whose `phase` is moved
only by `TurfSteps`, the rows of [`steps.lres`](steps.lres):

```
Peace --stir--> Contested --declared | escalates--> War --captured | held--> Cooldown --settled--> Peace
                Contested --claim--> Cooldown (nobody held it)      Contested --calms--> Peace
```

- **stir**: a crew that may contest the owner (and is not the owner) reaches `contest_at`.
- **claim**: nobody holds it and the challenger reaches the territory's `capture_at` (or the settings').
- **declared** (`crew_declare_war`, a rank with `war`; the action `TurfDeclare`) and **escalates** (the challenger reaches
  `war_at`): a war begins if the relation between the owner and challenger has `war`. It lasts `war_secs`.
- **captured**: at the end the attacker has more kills, or on a tie more influence than the owner's plus `defender_pct`;
  the owner changes and the old owner's influence halves. **held**: otherwise; the attacker's influence goes.
- **calms**: the challenger falls below half of `contest_at`, or may no longer contest (they became allies).
- **settled**: `cooldown_secs` have passed.

The timers and the influence are the tick's; the rows only decide. An owned territory pays its `income` into the
owner's bank every `income_secs`.

## Bounties

`crew_bounty_place(who, target, amount)` puts money (within the settings' limits) on a player; bounties on one player
add. Whoever kills them through `crew_killed` is paid, by the relation's `bounty_pct` between the two crews (a war
can pay double, allies nothing).

## Facts

`crew_facts()` is a `Queue<CrewFact { what, who, other, crew, other_crew, map, key, index, amount, reason }>`:
`CREATED`, `DISBANDED`, `INVITED`, `JOINED`, `LEFT`, `KICKED`, `PROMOTED`, `BANK` (`index` 1 deposit, 2 withdrawal, 3
income), `LOOK`, `RELATION`, `PROPOSED`, `LEAD`, `TURF_PHASE`, `CAPTURED`, `DEFENDED`, `DECLARED`, `BOUNTY_PLACED`,
`BOUNTY_CLAIMED`, `KILL`, `FRIENDLY_FIRE`, `REFUSED` (`CREW_` prefixed). A verb that says no returns false (or -1) and
leaves `crew_why()` = `CREW_NO_CREW`, `_IN_CREW`, `_NAME_BAD`, `_NAME_TAKEN`, `_BROKE`, `_NOT_HOST`, `_NO_PERMISSION`,
`_FULL`, `_NOT_INVITED`, `_NOT_MEMBER`, `_OUTRANKED`, `_IS_LEADER`, `_BAD_RANK`, `_NO_SUCH_CREW`, `_SELF`, `_COOLDOWN`,
`_NO_PENDING`, `_LIMIT`, `_BAD_ID`, `_NO_TURF`, `_BAD_AMOUNT`, `_NOT_CONTESTED`, `_NO_WAR`.

## Verbs

| | |
| --- | --- |
| `crew_create`, `crew_disband`, `crew_invite`, `crew_join`, `crew_decline`, `crew_leave`, `crew_kick`, `crew_set_rank`, `crew_transfer`, `crew_set_open`, `crew_set_look`, `crew_deposit`, `crew_withdraw` | the crew |
| `crew_propose`, `crew_accept`, `crew_reject`, `crew_relation`, `crew_relation_key`, `crew_pending`, `crew_pending_by`, `crew_kills_of` | relations |
| `crew_add_influence`, `crew_report`, `crew_killed`, `crew_declare_war`, `crew_turf_sync`, `crew_bounty_place`, `crew_bounty_on` | influence, war and bounties |
| `crew_of`, `crew_rank_of`, `crew_can`, `crew_same`, `crew_count`, `crew_id_at`, `crew_exists`, `crew_find`, `crew_name`, `crew_tag`, `crew_bank`, `crew_emblem`, `crew_color_a/b`, `crew_is_open`, `crew_founder`, `crew_member_count`, `crew_member_at`, `crew_invited` | who and what |
| `crew_turf_count`, `crew_turf_key_at`, `crew_turf_owner`, `crew_turf_phase`, `crew_turf_challenger`, `crew_turf_lead`, `crew_influence`, `crew_war_left`, `crew_war_score`, `crew_owned_count`, `crew_owned_value`, `crew_territory_at`, `crew_owner_at` | territories |
| `crew_tick`, `crew_reset`, `crew_save`, `crew_load`, `crew_snapshot`, `crew_apply_snapshot`, `crew_system()` | the system (`PH_SIMULATE`, key `"crews"`) |

## Multiplayer: the host owns the crews

Everything that changes who is in which crew, what a bank holds, how crews stand and who holds a territory is
**host-authoritative**. Crew verbs check `CrewWorld.authority()` and a guest gets `CREW_NOT_HOST` and a `REFUSED` fact,
which the game turns into a request to the host; influence reports (`crew_report`, `crew_killed`,
`crew_add_influence`) and the tick do nothing on a guest. The host applies, and broadcasts what happened: the facts (each
complete: crews, players, the territory's map and key) for a change, and `crew_snapshot()` - the same text as the save
section - when a player joins; a guest calls `crew_apply_snapshot`. A player's id is the game's persistent account
id; crew ids are the host's and never reused, and every other name in the data (ranks, relations, emblems,
territories) is a key. The save keeps crews, members, pair standings, bounties and each territory's owner and
influence; invites and a war in flight are not saved (influence stays, so a contest comes back by itself).

## Tests

`ludic test packages/ludic.crews`: geometry of the three shapes, founding, invites and joining, ranks and outranking,
the bank and its daily limit, disbanding, a guest refused, relations (mutual, hold, rivalry), influence from reports,
kills and presence with decay and the cap, a territory taken from nobody, a turf war through every phase (declared,
scored, captured, held, tied), friendly fire, bounties, income, facts, and the save and a guest's snapshot.
