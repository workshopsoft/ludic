# ludic.lobby

Who plays with whom. Sessions of a kind (public, invite-only, friends, crew, solo, a job's instance), who may
join them and how a player finds one (by kind, region, ping, skill, crew, a friend already in it, a quick join), the
moves between a freemode session and a job's instance and back, host migration with the host's state handed on, join in
progress, kicks and vote-kicks, passive mode, and anti-grief rules as data. Uses
[`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.lobby"
```

It is the layer above [`ludic.session`](../ludic.session/README.md) (the roster and roles of a party) and
[`ludic.net`](../ludic.net/README.md) (how its messages travel): a lobby's members are the players those carry, and what the
lobby decides - let this one in, hang up on that one, take the session over, go to that other session - comes out as
**facts** the game carries out with them. Nothing here opens a socket. An optional Steam lobby is a port
(`LobbyOutside`): a listed session is published there, a search's answers come back through `lobby_learn`.

## The data

All open, append-only, keyed registries (`def SessionKinds from "kinds.lres"`).

| registry | a row is |
| --- | --- |
| `SessionKinds` (`SESK_*`) | a kind: `join` (`LBJ_PUBLIC`, `_INVITE`, `_FRIENDS`, `_CREW`, `_SOLO`, `_CLOSED`), `listed`, `capacity`, `world` (freemode) or `job` (an instance), `migrate`, `jip` (join in progress), `passive`, `vote_kick`, `segregate` (bad sport with bad sport), `region_lock`, `ping_max`, `skill_band`, `quick`, `rules`, `min_open`, `ready_secs`, `idle_secs`, `reserve_secs`, `checkpoint_secs`, `ban_secs` |
| `LobbyRegions` (`REGION_*`) | a region: a `group` (regions of one group are near enough), `ping_max` |
| `AntiGriefRules` (`AGR_*`) | `friendly_fire` (percent between crew and team mates), `passive_immune`, `spawn_protect`, `passive_cooldown`, `offence_gap` |
| `LobbyOffences` (`GOFF_*`) | an offence under a rule: `what` (`LBO_KILL_PASSIVE`, `_KILL_PROTECTED`, `_KILL_FRIEND`, `_QUIT_JOB`, `_VOTE_KICKED`, `_DISRUPT`), `points`, `ghost_secs` |
| `BadSportTiers` (`BSPORT_*`) | the `pool` a player with at least these `points` is matched in, and its `decay_per_day` |

## The phases: a `@Machine`

`LobbySession.phase` is an enum field moved only by the machine `LobbySteps`, whose rows live in [`steps.lres`](steps.lres) and
which a studio edits as a graph:

```
Forming --open--> Open --idle--> Closed                      a freemode session
Forming --start--> Running --job_over--> Returning --back--> Closed      a job's instance
Forming --aborted--> Returning ;  Running --job_left--> Closed ;  Closed --reopened--> Forming
```

A freemode session opens when it has its `min_open` members and closes `idle_secs` after it empties (seats kept for players
away on a job count as someone). A job's instance starts when everyone in it is `lobby_ready` or `ready_secs` are up (whoever was
not is sent back); it is Running until `lobby_job_ended`, when its players go home. A closed session stays readable for
five seconds, and `lobby_reopen` can ask it back in that time. What a phase's beginning means (who moves where) is done by the
lobby and said as `LBF_PHASE`.

## Admission

`lobby_can_join(session, who, ping)` answers `LBR_OK` or what stops them, in this order: `LBR_CLOSED` (closed, returning, locked by
its host, `LBJ_CLOSED`, a job that is over), `LBR_JIP` (a job that has begun and does not take players in progress), `LBR_BANNED`,
`LBR_FULL` (members and kept seats, less the seat the joiner holds), `LBR_SOLO`, `LBR_INVITE` / `LBR_FRIENDS` (`LobbyWorld.is_friend(host,
who)`) / `LBR_CREW` (a crew of the host's), `LBR_REGION` (`region_lock`: the group), `LBR_PING` (the kind's, else the region's),
`LBR_SKILL` (`skill_band` against the session's average), `LBR_POOL` (`segregate`). **A join code** from the host
(`lobby_join_code`) waives only what a kind asks of strangers - the invitation, the friendship, the crew: never room, a ban, or a
shut door. Every refusal is an `LBF_REFUSED` fact and `lobby_why`.

## Finding a session

The game tells the lobby who a player is (`lobby_player(who, crew, skill, region)`). `lobby_find(who, kind, region, ping)` ranks the
sessions this lobby keeps and the listings it has `lobby_learn`ed of, best first, offering only what the player could join: a friend in
it counts most, then a crew mate, the same region, nearness in skill, and fuller beats emptier (with a listing judged on what it says of itself).
`lobby_quick_join(who, kind, region, ping, create)` joins the best session here (its id), or says to connect to a listing (`LBF_CONNECT`,
returns -2), or makes a new session of the kind when `create`, else -1; finding nothing also asks outside (`LobbyOutside.search`).

## Freemode and jobs

`lobby_start_job(session, by, job, instance_kind, who)` makes an instance of a `job` kind whose parent is the session, hosted by `by`, and moves `by`
and the members of `who` who are there into it; each keeps a seat in the session they left for `reserve_secs`. When the job ends
(`lobby_job_ended`) everyone goes back: to the session they came from if it is still there and has their seat, else to the session the
job began in, else to a **new session of the same kind**, which those who shared the lost one share (`LBF_TRANSFER`: `LBT_TO_JOB`,
`_FROM_JOB`, `_ELSEWHERE`). A player who joins a job in progress from another session goes back to that one. Leaving a job that has begun
scores `LBO_QUIT_JOB` under the rules. `lobby_move(who, to, ping)` is a move of a player's own (an invitation taken).

## Host migration

The heir is a **pure function of the roster** - the members who `can_host`, the one who has been there longest, ties to the lower id
(`lobby_heir`) - so every machine that knows the roster picks the same one without a word between them. A kind with `migrate: false` closes
with its host (everyone gets `LBF_DROP`).

The host's state is handed on **while the host lives**: every `checkpoint_secs`, on the machine `lobby_set_local` names as the host's, the lobby says
`LBF_CHECKPOINT_DUE`, asks the game to export it (`LobbyWorld.export(session)`), keeps it with a revision, and says to send it
(`LBF_CHECKPOINT_SENT`); members keep the latest (`lobby_checkpoint_keep`). When the host goes, the machine that becomes host is
handed the last state it kept (`LobbyWorld.import(session, state, revision)`, and `LBF_HOST_STATE`).

**One deterministic lobby on every machine.** `lobby_snapshot(session)` is the session as a value (its roster with flags and origins, bans, invitations,
seats kept, code, phase inputs) and `lobby_adopt(value)` makes or updates a mirror of it (the session's `uid` is the same everywhere; ids are
each table's own). A mirror runs the same machine from the same roster, so the same phases and the same facts follow: each machine reacts to the
facts about its own player (a `LBF_TRANSFER` of me: connect there), and the machine that becomes host carries on from where the old one was.

## Kicks and votes

`lobby_kick(session, by, target, secs)` is the host's (a ban of `ban_secs` when `secs` < 0). `lobby_votekick(session, by, target)` opens a vote: at
least three in the session, a kind that has votes, one at a time, a minute between a player's votes and between the session's. The opener
votes for; the target cannot vote; `lobby_vote(session, who, yes)`; a majority of everyone else for or against ends it at once, time (thirty
seconds) decides by those who voted (a tie fails). A vote that passes puts the target out with a ban and scores `LBO_VOTE_KICKED`. A vote
about a player who leaves, or by one who does, is over.

## Passive mode and anti-grief

`lobby_set_passive(session, who, on)` (the kind must allow it; leaving it waits the rules' `passive_cooldown`). The game asks
`lobby_may_hurt(session, attacker, victim)` before damage - a percent: 0 to a player in passive mode (when the rules say so), 0 while
protected after spawning (`lobby_spawned`), 0 from or to a ghost, 0 from a player in passive mode, the rules' `friendly_fire` between crew or team mates
(`lobby_set_team`), else 100 - and reports a kill (`lobby_report_kill`), which the rules score as what it was: a passive player, one under
protection, one of their own. An offence is its row's bad-sport points and a **ghosting** (`ghost_secs`: they do and take no harm); the same offence again
within `offence_gap` counts once. Bad sport fades by the day (`LobbyWorld.day`, each tier's `decay_per_day`) and a player's pool (`lobby_pool`) follows the
tier their points reach; `LBF_BAD_SPORT` says when it moved. `lobby_add_bad_sport` is the game's own scoring.

## Ports

```ludic
export port LobbyWorld {
  is_friend: fn(int, int) -> bool       # the game's (Steam's) friends (nobody)
  day: fn() -> int                      # bad sport fades by the day (1)
  export: fn(int) -> Val                # the host's state, to hand on (null: none)
  import: fn(int, Val, int) -> void     # this machine is host now: take it
  seed: fn() -> int                     # the dice of join codes and session uids
}
export port LobbyOutside {
  publish: fn(int, int, int, int) -> void    # (session, kind, capacity, members) make or update a listing
  withdraw: fn(int) -> void
  search: fn(int, int) -> void               # (kind, region) ask for listings: answers come back as lobby_learn
}
```

## Verbs

| | |
| --- | --- |
| `lobby_create(kind, host, region)`, `lobby_join`, `lobby_join_code`, `lobby_leave`, `lobby_gone(who)`, `lobby_invite`, `lobby_lock`, `lobby_close`, `lobby_reopen` | sessions and their roster |
| `lobby_can_join`, `lobby_why`, `lobby_find`, `lobby_match_session` / `_listing` / `_score`, `lobby_quick_join`, `lobby_learn`, `lobby_forget` | admission and matchmaking |
| `lobby_start_job`, `lobby_ready`, `lobby_job_ended`, `lobby_move` | jobs |
| `lobby_heir`, `lobby_set_local`, `lobby_set_can_host`, `lobby_checkpoint_set` / `_keep` / `lobby_checkpoint`, `lobby_snapshot`, `lobby_adopt` | hosts and their state |
| `lobby_kick`, `lobby_votekick`, `lobby_vote`, `lobby_vote_open`, `lobby_vote_target` | putting players out |
| `lobby_set_passive`, `lobby_may_hurt`, `lobby_report_kill`, `lobby_offence`, `lobby_spawned`, `lobby_protected`, `lobby_ghosted`, `lobby_passive`, `lobby_set_flag`, `lobby_set_busy`, `lobby_set_team`, `lobby_ping` | flags and rules |
| `lobby_player`, `lobby_bad_sport`, `lobby_pool`, `lobby_add_bad_sport` | players |
| `lobby_exists`, `lobby_sessions`, `lobby_session_at`, `lobby_session_of`, `lobby_phase`, `lobby_kind_of`, `lobby_host`, `lobby_is_host`, `lobby_count`, `lobby_capacity`, `lobby_members`, `lobby_code`, `lobby_uid`, `lobby_by_uid`, `lobby_by_code`, `lobby_parent`, `lobby_job`, `lobby_region`, `lobby_flags`, `lobby_ping_of` | what a session is |
| `lobby_tick(dt)`, `lobby_reset`, `lobby_save` / `lobby_load`, `lobby_system()` | the clock (`PH_SIMULATE`); a save section holding each player's bad sport |

## Facts

`lobby_facts()` is a `Queue<LobbyFact>` (`what`, `session`, `to`, `who`, `by`, `kind`, `n`, `reason`, `x`, `text`): `LBF_CREATED`, `_CLOSED`, `_JOINED`, `_LEFT` (`n`: `LBL_*`), `_REFUSED`
(`reason`: `LBR_*`), `_KICKED`, `_DROP` (disconnect them), `_VOTE_OPENED`, `_VOTE_RESOLVED`, `_HOST_MIGRATE`, `_HOST_STATE`, `_TRANSFER` (`n`: `LBT_*`), `_PHASE`, `_FLAG`, `_OFFENCE`, `_GHOST`,
`_PUBLISH`, `_WITHDRAW`, `_CHECKPOINT_DUE`, `_CHECKPOINT_SENT`, `_CONNECT` (quick join found a listing), `_BAD_SPORT`, `_INVITED`, `_RESERVE_LAPSED`.

## Tests

```bash
ludic test packages/ludic.lobby
```

On a fixture of kinds, regions, rules and a fake world: a session made and listed, every join rule and what a refusal says, matchmaking and quick join, an instance and
everyone's way home (their session, the job's, a new one), seats kept, join in progress, the heir and the state handed to it, a session that cannot migrate, a session
reopened, a session adopted by another machine, kicks and every turn of a vote, passive mode, spawn protection, friendly fire, what a kill is scored as, ghosting,
bad sport's pools fading by the day, and the save.
