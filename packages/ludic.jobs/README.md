# ludic.jobs

Work a player takes on for pay: written jobs offered by standing and story, boards of posts rolled
by the day, progress counted from what happens and read back from what the state proves, handing
in, and the reward paid through the game. Uses [`ludic.base`](../ludic.base/README.md) and nothing
else.

```ludic
import "ludic.jobs"
```

A job is `(kind, param, need)` plus a reward (`money`, `rep`), a scope (`JOBS_SELF` yours,
`JOBS_PARTY` the party's) and a gate (`minrep` in its scope, `minstage` of the game's story). What a
kind measures is the game's: it counts a deed with `jobs_count(kind, param, n)`, and answers
`JobsWorld.evidence(kind, param)` with what the state already proves (-1: nothing). The game fills
the registries - `def Jobs from "jobs.lres"`, `def JobBoards from "boards.lres"` - and words every
line itself.

## The rules it keeps

1. **Events count, state proves, progress only goes up.** A job under way takes `jobs_count` deeds
   and is reconciled every tick against the evidence, taking whichever is further; work done
   before a written job was taken counts, and a post counts only what came after it went up.
2. **A job with a need is ready when it is met**; one with `need: 0` (and no kind) is the game's
   own play, which says so with `jobs_ready` or pays at once with `jobs_complete`.
3. **A board rolls from its own dice.** `jobs_morning()` replaces every empty, stale (`keep` days)
   or earlier-finished post, seeding the jobs' `Rng` from the day, the board, the slot and how many
   posts came before, and asking `JobsWorld.roll(board, slot)`, which draws with `jobs_roll` and
   posts with `jobs_post`. The same day rolls the same board on every machine.
4. **Scopes have keepers.** Where `JobsWorld.owns(scope)` is false (a guest's party jobs),
   `jobs_count`, the recheck and the morning leave them alone; the keeper applies another member's
   deed with `jobs_count_in(scope, ...)` and a guest takes the keeper's word with `jobs_set` /
   `jobs_post_set`.
5. **Paid once, through a port.** `jobs_hand_in` / `jobs_post_hand_in` (or the moment an `auto`
   board's post is met) calls `JobsPay.reward(scope, money, rep)`.

## The ports

```ludic
export port JobsWorld {
  rep: fn(int) -> int            # standing in a scope (unbound 0)
  stage: fn() -> int             # the story's stage (0)
  open: fn(int) -> bool          # a job the game allows today (all)
  evidence: fn(int, int) -> int  # (kind, param) as the state proves it (-1)
  day: fn() -> int               # (1)
  owns: fn(int) -> bool          # this machine keeps the scope (all)
  roll: fn(int, int) -> void     # (board, slot): post with jobs_post (nothing)
}
export port JobsPay { reward: fn(int, int, int) -> void }   # (scope, money, rep), required
```

## API

| | |
| --- | --- |
| `JobDef { key, group, vendor, kind, param, need, money, rep, minrep, minstage, scope, title, text, how, icon }`, `open registry Jobs ... as JOB` | a written job (`group` is the game's list, `JOBS_GROUPS` of them) |
| `JobBoard { key, slots, keep, auto, refill, scope }`, `open registry JobBoards ... as BOARD` | a board of posts |
| `JOBS_OFFERED`, `JOBS_ACTIVE`, `JOBS_READY`, `JOBS_DONE`; `JOBS_SELF`, `JOBS_PARTY` | states and scopes |
| `jobs_state(i)`, `jobs_have(i)`, `jobs_offered(i)`, `jobs_under_way(i)`, `jobs_ready_now(i)` | a job |
| `jobs_take(i)`, `jobs_ready(i)`, `jobs_hand_in(i)`, `jobs_complete(i)`, `jobs_set(i, state, have)` | its verbs |
| `jobs_set_have(i, v)`, `jobs_add_have(i, n)`, `jobs_mark(i, bit)` | the game's own play |
| `jobs_count(kind, param, n)`, `jobs_count_in(scope, kind, param, n)`, `jobs_recheck()` | progress |
| `jobs_at(group, vendor)`, `jobs_taken(group)`, `jobs_shown(group, most)`, `jobs_first_open(group)`, `jobs_done(group)`, `jobs_set_done(group, n)` | lists and counts |
| `jobs_morning()`, `jobs_roll(lo, hi)`, `jobs_post(b, s, kind, param, need, money, rep)`, `jobs_config_seed(seed)` | posting |
| `jobs_slots(b)`, `jobs_posted(b)`, `jobs_post_kind / _param / _need / _have / _money / _rep / _state / _day(b, s)`, `jobs_posts_done(b)`, `jobs_total(b)` | the boards |
| `jobs_post_hand_in(b, s)`, `jobs_post_set(b, s, ...)`, `jobs_set_total(b, n)` | a post's verbs |
| `jobs_give_up(i)`, `jobs_back_on(i)`, `jobs_post_give_up(b, s)` | letting one go: a written job is offered again from the next day (the day back is saved with it), a post comes down and the morning replaces it; an auto board's posts are never taken, so never given up |
| `jobs_facts() -> Queue<JobsFact>` | `{ what: JOBS_F_OFFERED / _PROGRESSED / _COMPLETED / _HANDED_IN / _GIVEN_UP, job, board, slot, kind, param, have, need, money, rep, scope }` |
| `jobs_system()`, `jobs_party_system()` | `"jobs"` (yours, the tick) and `"jobs.party"` (the party's), each saving its scope's jobs and boards by key |

## Tests

```bash
ludic test packages/ludic.jobs
```
