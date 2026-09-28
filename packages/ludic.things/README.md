# ludic.things

The things placed in a world - a tent, a fire ring, a branch on the ground, a snare - and the
kinds they are. The game names the kinds and draws them; the package keeps every Thing, answers
where they are, asks a kind what it does, reports what happened, and saves the ones worth
keeping. Uses [`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.things"
```

## A Thing

```ludic
property Thing {
  uid, kind, id          # unique for the run; its place in ThingKinds; what the kind says it means
  look                   # how the game draws it ("" is not drawn)
  x, y, z, yaw
  owner                  # whoever put it down, -1 the world's own
  active                 # false: taken, hidden, used up for now
  reach                  # how close it is used from (0: its kind's)
  timer, used, n         # state the kind decides the meaning of
  sx, sz, syaw           # where using it puts the user, and which way that faces
  shared                 # the game copies it to others (a party)
}
```

## The kinds

`ThingKinds` is an `open registry`, filled by the game - usually one `def` per kind in one file,
so `TH_<KEY>` is the order they are written in. A kind's behaviour is function values; a null one
is a question the kind ignores.

```ludic
def ThingKinds fire { name: "The campfire", prompt: fn fire_prompt, use: fn fire_use }
def ThingKinds lure { name_of: fn bait_name, tick: fn bait_wear, put_down: true, saved: true }
```

| field | |
| --- | --- |
| `name`, `name_of: fn(Thing) -> string` | what it is called (`name_of` answering "" falls back to `name`) |
| `prompt: fn(Thing) -> string`, `use: fn(Thing)` | what using it would do, and doing it |
| `tick: fn(Thing, float)` | hours of the world's clock, for every active one |
| `reach`, `reach_of: fn(Thing) -> float` | how close it is used from |
| `personal` | one belongs to whoever put it down |
| `saved` | the save section keeps a placed one (the port has the last word) |
| `put_down` | set down by someone rather than grown by the world: a restock leaves it (the port has the last word) |
| `keeps` | keeps its `used` through a restock |

**A removed Thing's record is placed again.** Ludic frees nothing, and a world places and takes
away Things all day, so `thing_remove` keeps the record and `thing_put` / `thing_spawn` make the
oldest one again - set back as new, with a new `uid` - once 32 are waiting. Hold a Thing across a
removal only by its `uid` (`thing_by_uid`), never by the record.

## The port

Every member has a default, so any may be left out of the `bind`:

```ludic
export port ThingsWorld {
  ground: fn(float, float) -> float   # the height a Thing stands at (unbound: 0)
  placed: fn(Thing)                   # it exists now: draw it
  removed: fn(Thing)                  # gone for good: stop drawing it
  shown: fn(Thing)                    # its `active` changed
  moved: fn(Thing)                    # it stands somewhere else
  keeps: fn(Thing) -> bool            # the save carries it (unbound: its kind's `saved`)
  put_down: fn(Thing) -> bool         # a restock leaves it be (unbound: its kind's `put_down`)
  restored: fn(Thing)                 # a load put it back, after `placed`
}
```

`placed`, `removed`, `shown` and `moved` are called at once, inside the verb, so the game can make
the actor the moment the Thing exists (a caller often scales or tints it on the next line).

## API

| | |
| --- | --- |
| `thing_spawn(kind, look, x, y, z, yaw, id) -> Thing`, `thing_put(kind, look, x, z, yaw, sink, reach, id) -> Thing` | a new Thing, at a height or on the ground set into it by `sink` |
| `thing_remove(t)`, `things_drop(gone: fn(Thing) -> bool)`, `things_clear()` | gone for good (told to the port); a new world, quietly |
| `things_reserve(n)`, `things_spare_count()` | room in the grid for `n` Things, made once at the start; how many removed records wait to be placed again |
| `thing_move(t, x, z, yaw)`, `thing_move_to(t, x, y, z, yaw)` | on the ground there, or at a height |
| `thing_hide(t)`, `thing_show(t)`, `thing_set_active(t, on)` | `active`, told to the port |
| `things_all()`, `things_count()`, `things_ready()`, `thing_by_uid(uid)` | every Thing, in the order placed; whether a world was ever set out |
| `thing_find(kind, id)`, `thing_nearest(kind, x, z)`, `things_within(x, z, r)`, `things_each(kind)`, `things_each_all(kind)`, `thing_dist2(t, x, z)` | where they are: only active ones answer except the `_all`; a kind below 0 is any; `within` is nearest first |
| `thing_name(t)`, `thing_prompt(t)`, `thing_use(t)`, `thing_can_use(t)`, `thing_reach(t)`, `thing_kind(t)`, `thing_is_personal(t)`, `thing_is_put_down(t)` | the dispatcher |
| `things_tick(hours)`, `things_restock()` | every active kind that ticks; every Thing the world grew back and unused |
| `things_facts() -> Queue<ThingFact>` | `{ what, uid, kind, id, owner, x, z }`: `THING_PLACED`, `THING_REMOVED`, `THING_USED` |
| `thing_kind_ok(k)`, `thing_kind_by_key(key)` | the kinds |
| `things_system() -> System` | `"things"`, `PH_COMMIT`: its save section - every active Thing the port keeps, its kind by KEY, so the game may reorder its kinds - and a reset that removes the kept ones for the load to put back |

## Tests

```bash
ludic test packages/ludic.things
```
