# ludic.steps

Chapters made of steps. A step is three numbers - a **kind**, a **param** and a **need** - and a
question about the state of the game ("five firewood gathered", "reputation 25", "all three signs
stood at"), never a count of what happened while its chapter was open: so a step met before its
chapter opens ticks the moment it is looked at. A chapter is a table of up to six steps; the arc
is a table of chapters; the current one ticks its steps as they are met and moves on when all
are. With company, every player's share of each step is pooled as its kind says. Uses
[`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.steps"
```

The kinds, the chapters and every word about them are the game's content: the package knows a
kind's **shape** and **pool**, never what it measures or what a chapter is called.

## Kinds

```ludic
property StepsKind {
  key: string
  shape: int     # STEPS_SHAPE_YES (met or not), _COUNT (a number against the need),
                 # _MASK (bits counted against the need), _MASK_ALL (every bit of param)
  pool: int      # STEPS_POOL_WORLD (the same for everyone: asked of this machine), _ANY (anyone
                 # having done it), _SUM (the counts add up), _OR (the masks union), _MAX (the
                 # best one), _EACH (every player needs their own)
  shows: bool    # a panel shows its count against what it wants
}
```

A kind is its place in the list handed to `steps_kinds`, which is how a game's registry
(`registry StepKinds of StepsKind from "steps.lres"`) hands it in.

## The port

```ludic
port StepsWorld {
  value: fn(int, int, int) -> int   # (kind, param, player): a count, a mask, or 1/0; 0 is this machine
  party: fn() -> bool               # is a party playing (unbound: no)
  present: fn(int) -> bool          # is a seat taken (unbound: seat 0 only)
}
```

`value` has no default: a game that uses steps binds it (`bind StepsWorld { value: fn ... }`).

## API

| | |
| --- | --- |
| `steps_kinds(ks)`, `steps_config(players)` | the kinds; how many seats a party has (12) |
| `steps_eval(kind, param, need)`, `steps_got(kind, param)`, `steps_want(kind, param, need)`, `steps_shape`, `steps_pool`, `steps_shows` | a step against this machine's state; its count (-1 when not shown) and what it wants |
| `steps_mine(kind, param, need)`, `steps_from(kind, param, need, v, players, have)`, `steps_got_from(kind, param, v)` | this machine's share (a mask, a count, 1/0, nothing for the world's), and a verdict or a count from shares already pooled |
| `steps_arc_clear()`, `steps_chapter_add() -> int`, `steps_add(kind, param, need) -> bool` | build an arc (false: no chapter, or it has `STEPS_PER_CHAPTER`) |
| `steps_count()`, `steps_in(ch)`, `steps_kind(ch, i)` / `_param` / `_need`, `steps_kind_at(k)` / `_param_at` / `_need_at` | the tables, by chapter and step or by the flat index `ch * STEPS_PER_CHAPTER + i` |
| `steps_current()`, `steps_done_mask()`, `steps_done(i)`, `steps_finished()`, `steps_set_current(ch)`, `steps_set_done(mask)` | the progress, and setting it outright (a load, the host's word, a test) |
| `steps_check()` | once a frame on the machine that owns the story: `STEPS_MET` for each step newly met, `STEPS_CHAPTER` and the next chapter when all are |
| `steps_check_at(ch, i)`, `steps_wants(kind, param)` | a step of any chapter against this machine; is an open step of the current chapter asking for a kind (and a param, unless < 0) |
| `steps_my_shares() -> []int`, `steps_share(p, ch, shares)`, `steps_share_of(p, i)`, `steps_leave(p)`, `steps_party_reset()` | this machine's shares to send; a teammate's as they arrived (ignored when about another chapter); a seat emptied |
| `steps_met(i)`, `steps_party_got(i)`, `steps_players()`, `steps_each(i)`, `steps_lacking(i)` | the party's verdict and count for step i of the current chapter; how many seats are taken, how many carry an EACH step's thing, and which do not |
| `steps_facts() -> Queue<StepsFact>` | `{ what, chapter, step }` |
| `steps_popcount(m)`, `steps_reset()` | bits in a mask; back to nothing (tests) |

## Tests

```bash
ludic build packages/ludic.steps/tests/steps_test.ludic --headless -o /tmp/steps_test && /tmp/steps_test
```

A fake world of values and seats: every shape, an arc that ticks and moves on (and a step met
before its chapter), the six-step cap, and every pool across a party, a leaver and a share about
another chapter.
