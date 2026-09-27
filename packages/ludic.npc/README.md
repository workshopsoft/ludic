# ludic.npc

The other people in a place: each with a routine by the hour rather than an intelligence - where
they start, where they go and what they do there, when they walk out - walking between spots and
round whatever is in the way, never into the water, turning to face a player who comes near, and
saying one line at a time from a table of lines. Uses [`ludic.base`](../ludic.base/README.md) and
nothing else.

```ludic
import "ludic.npc"
```

The package owns the people's state, the census, the walk, the acts, the lines, its own dice and a
guest's copy of a host's people. It never draws: the port says a person was `born` (make an actor,
key it by the person's `slot`, or `id` across machines) and `gone`, and the game reads `x`, `y`,
`z`, `yaw`, `act`, `stalk` and `phase` (2.6 a metre walked) every frame to pose it. Clips are the
game's too (`NpcAct.clip` is a hint: `"walk"`, `"idle"`, or `""` for a pose of its own).

## Four tables the game fills

- **`NpcKinds`** - a kind of person: `weight` in the census draw (`night`: the only kinds drawn
  after dark), whether it `stays` the night, `leave_lo` .. `leave_hi` (the hour it walks out),
  `notice` (m it turns to face a player), `start` (where a new one goes: call
  `npc_start_near(p, x, z, r0, r1)`), `plan` (the first word on what next; true: decided) and
  `steps`, its routine.
- **`NpcStep`** (inside a kind) - in the hours `from` .. `to` (round midnight when `from > to`),
  `weight` of the draw, go to `spot` (`near` .. `far` m, `n` the spot's own number) and do `act`
  for `lo` .. `hi` seconds. A step whose spot cannot be found gives way to the next one in the table.
- **`NpcSpots`** - where a step goes; `find(p, step)` sends the person (`npc_go` / `npc_do`, or
  `npc_step_go`) or says it cannot. The package's own: `here`, `home`, `near_home`, `near_here`,
  `shore_home`, `shore_here` (facing the water) and `wander`; a game adds its own (a sign, an animal).
- **`NpcActs`** - what somebody does; the package's `walk` (`NPCA_WALK`) and `idle` come first.
  `turns` (false: keeps its eyes on its work), `clip`, and `tick(p, dt)` (the game's while it lasts;
  true: decided).
- **`NpcNames`** (`name`, `body`) and **`NpcLines`** - see below.

A kind's `.lres` may name functions (`start: fn my_start`), and a step list is `[{ ... }, ...]`.

## The rules it keeps

1. **A routine, not a mind.** A person plans on arriving and when its act runs out: the kind's
   `plan`, then a weighted draw among its steps for this hour, then standing a while.
2. **Nobody walks into the lake or up a scramble**: a step into water (0.4 m) or up more than 1.4x
   the step is refused; eight steps round are tried, and a target that gets no closer for twenty
   seconds is given up (three times: a few steps anywhere walkable).
3. **Nobody stops where the place says not to** (`NpcWorld.allowed`: a player's camp). They may
   walk through; an act begun there walks out first.
4. **They face whoever came over to talk**, within the kind's `notice` - unless creeping or at an
   act that does not `turns` - and go back to their errand when the player walks off. A player
   coming within notice is a `Greeted` fact, once, until they have gone half as far again.
5. **The census is counted, not tallied**, on the half hour: up to `NpcWorld.want()` (and never
   past `npc_config`'s cap), plus `NpcWorld.extra()` whatever the crowd.
6. **They leave only out of every player's sight**: after their hour at 120 m, at night (by 22:00,
   except those who `stay`) at 70 m, and a crowd over what is wanted at 150 m - never while out
   for something (`goal >= 0`).
7. **No name twice**: not another person's, not one the place keeps (`NpcWorld.taken`), not one
   that left lately.
8. **Posts** (`npc_place`: a vendor) never walk, are never counted and never leave; they turn to a
   player within notice and back to their stance.

## Lines as data

```
hush { prio: 5, act: NPCA_PHOTO, fill: true }               # the story's words (NpcTalk.say)
sighting { prio: 4, chance: 30, fill: true }                # considered three times in ten
water { prio: 3, act: NPCA_WATER, text: "Boil it, even up here." }
hello { prio: 1, text: "Morning.", choices: [{ text: "Any fish?", line: "fish", code: 7 }] }
```

The highest `prio` with anything to say wins, each line of it in table order given its `chance`;
a `fill` line's words are `NpcTalk.say(p, line)`, and "" means it has nothing true to say now.
`npc_talk` picks one (a `Talked` fact); `npc_choose` answers a choice with the line it names (a
`Talked` fact carrying the choice's `code`). A vendor's greeting is `NpcTalk.greeting(p)`.

## The ports

```ludic
export port NpcWorld {       # every member has a default: a flat dry field at noon, one player, nobody wanted
  ground, water, slope: fn(float, float) -> float
  allowed: fn(float, float) -> bool                  # may a person stop here
  push: fn(x, z, r, feet, head) -> bool, pushed_x, pushed_z   # a walker slid clear of still things (r 0.35)
  clear: fn(ax, ay, az, bx, by, bz) -> bool          # no still thing between: npc_line_ok asks it at 1 m
  hour: fn() -> float, day: fn() -> int              # the clock
  players: fn() -> int, player_on: fn(int) -> bool, player_x / player_z: fn(int) -> float
  want: fn() -> int, extra: fn() -> int              # the census: how many, and a kind brought out regardless (-1)
  origin_x / origin_z: fn() -> float                 # where anyone goes when nowhere else will do
  next_id: fn() -> int, body_of: fn(int) -> int      # an id across machines; a look seed's body
  taken: fn(string) -> bool                          # a name the place keeps
  born / gone: fn(NpcPerson) -> void                 # draw it, stop drawing it
  way: fn(NpcPerson, x, z) -> bool, way_x, way_z      # the next corner of its way toward (x, z)
}
export port NpcTalk { say: fn(NpcPerson, int) -> string, greeting: fn(NpcPerson) -> string }
```

**A person walks by the world's way where the world has one.** `way` is asked for the next corner
toward where it is going - every half second, on reaching the corner, and at once for a new target -
and the person walks corner to corner, but begins its errand only at the target itself. With no
answer (the default) it walks straight and steps round what is in the way, as before; the step
round and the twenty seconds' give-up stay as the fallback. Maroon Lake binds `way` to its navmesh
by a person's taste.

## API

| | |
| --- | --- |
| `NpcPerson`, `npc_walkers()`, `npc_posts()`, `npc_at(slot)`, `npc_post(i)`, `npc_by_id(id)`, `npc_count()`, `npc_max()` | the people (`goal`, `subj`, `note`, `note_h`, `flags` are the game's) |
| `npc_config(max)`, `npc_seed(n)`, `npc_rnd()`, `npc_between(lo, hi)`, `npc_secs(lo, hi)` | the cap and the package's own dice |
| `npc_tick(dt)`, `npc_posts_tick(dt)`, `npc_census_now()`, `npc_hold(on)`, `npc_reset()`, `npc_clear()` | a step where the place is run (or of the posts alone), the census at once, held still, a new trip, a new place |
| `npc_spawn(kind)`, `npc_place(kind, x, z, yaw, name, look)`, `npc_retire(p)`, `npc_start_near(p, x, z, r0, r1)`, `npc_set_at(p, x, z)` | making and leaving |
| `npc_go(p, x, z, act, secs)`, `npc_do(p, act, secs)`, `npc_face(p, x, z)`, `npc_face_ahead(p)`, `npc_set_home_face(p, x, z)`, `npc_plan(p)`, `npc_steps(p, steps)`, `npc_step_go(p, step, x, z)`, `npc_wander(p)` | the routine |
| `npc_walk(p, dt)`, `npc_act(p, dt)`, `npc_notice(p)` | a person's step |
| `npc_walkable(x, z)`, `npc_line_ok(ax, az, bx, bz)`, `npc_spot_near(x, z, d0, d1)`, `npc_toward(ax, az, bx, bz, d)`, `npc_shore(x, z, r)`, `npc_px()`, `npc_pz()`, `npc_wx()`, `npc_wz()` | the ground |
| `npc_near(x, z)`, `npc_near_i()`, `npc_d(...)`, `npc_wrap(a)` | the nearest player, distances, angles |
| `npc_pick_name(body)`, `npc_name_used(n)`, `npc_name_clashes()` | names |
| `npc_talk(p, player)`, `npc_line_for(p)`, `npc_words(p, line)`, `npc_said()`, `npc_choose(p, line, c, player)`, `npc_talked_today(p)`, `npc_greeting(p)` | talk |
| `npc_mirror(on)`, `npc_mirroring()`, `npc_put(slot, id, kind, look, seed, name, hx, hz)`, `npc_heard(slot, x, y, z, yaw, speed, act, stalk)`, `npc_heard_lately(p)`, `npc_mirror_tick(dt)` | a guest's copy of the host's people |
| `npc_facts() -> Queue<NpcFact>` | `NPC_F_GREETED` (`player`), `NPC_F_TALKED` (`player`, `line`, `choice`), `NPC_F_ARRIVED` (`act`), `NPC_F_STUCK` (`how` - `NPC_STUCK_DETOUR`, `_RETRY`, `_GAVE_UP` - at `x`, `z`: the way failed it and it fell back) |
| `npc_system() -> System` | `"npc"`, `PH_SIMULATE`, a reset and no tick; nothing saved |

## Tests

```bash
ludic test packages/ludic.npc
```
