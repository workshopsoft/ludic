# ludic.anim

The animation clips an animator keyed into a glTF, played on a render3d `Skin` through animation
graphs held as data: state machines with sub graphs, blend spaces, layers with bone masks, sync groups,
clip events and root motion (see "Animation graphs" below). `ludic.render3d` parses no animations and
offers a pose api (`skin_set_quat`, `skin_set_offset`, `skin_pose`) rather than a player, so the sampler
lives here. Uses `ludic_render3d` and nothing else: it reads the document `gltf_load` just parsed and
writes a Skin's pose. It asks the game nothing except, when the game binds it, where to put a clip's root
motion (the `AnimRoot` port).

```ludic
import "ludic.anim"
let m = gltf_load("assets/kit/hiker2", "hiker_m.gltf", "hiker_m")
anim_read_doc("assets/kit/hiker2")                 # straight after the load, before the next
let walk = anim_find("hiker_m_walk")
anim_play(sk, walk, t, idle, t2, 0.3)              # 70% walk, 30% idle, into the joint matrices
```

## API

| | |
| --- | --- |
| `Clip { name, dur, n, cnode, cpath, ckeys, coff, cvoff, times, vals }`, `AC_ROT`, `AC_POS` | a clip, its channels flattened: a channel's keys are `times[coff..coff+ckeys]`, its values 4 (rotation) or 3 (translation) per key from `cvoff` |
| `anim_read_doc(dir) -> int` | every rotation and translation channel of every animation in `gltf_doc`, reading the `.bin` beside it in `dir`; how many clips were new |
| `anim_find(name) -> Clip`, `anim_count()`, `anim_add(c) -> bool`, `anim_clear()` | the table, by name; a name already held is skipped on read and refused on add |
| `anim_play(sk, a, ta, b, tb, blend) -> bool` | `a` at `ta`, cross-faded toward `b` at `tb` by `blend` (0 all a, 1 all b; `b` may be null), folded into the joint matrices |
| `anim_mix(c, sk, t, w, rot, pos, hit)`, `anim_to_pose(sk, rot, pos, hit)`, `anim_key_at(c, ch, t)` | the pieces `anim_play` is made of, for a caller that mixes more than two |
| `anim_set_positions(on)`, `anim_positions()` | keyed translations applied or not (off: baking keys location on every bone, and rounding down an eighteen-bone chain is a collapsed animal) |
| `skin_joint(sk, name)`, `skin_joint_quiet(sk, name)` | a bone by name in the skin's OWN joints: a kit packs several rigs with the same bone names, and render3d's `skin_find` answers the file's first, which belongs to another rig (the pose is then stored and never drawn) |
| `anim_first_key(c) -> float` | the earliest key; a read warns when it is not zero |

## ozz-animation underneath

[ozz-animation](https://github.com/guillaumeblanc/ozz-animation) 0.17.0 (MIT, `native/LICENSE-ozz-animation.md`)
is compiled into `libludicozz` by `native/build.sh` from the pinned release: its base, its runtime jobs and
the offline builders for a skeleton and a clip. There is no bake and no new file. The skeleton is
built from a skin's parents and rest pose, taking only its own joints and their ancestors, because a
kit holds several rigs. Each clip is built from the channels `anim_read_doc` already read.

| | |
| --- | --- |
| `anim_oz_skel(sk) -> pointer`, `anim_oz_joints(s)`, `anim_oz_skel_free(s)` | a skin's skeleton |
| `anim_oz_clip(c) -> pointer`, `anim_oz_clip_bytes(c)`, `anim_oz_clip_free(c)` | a clip for that skeleton, compressed (translations only with `anim_set_positions`) |
| `anim_oz_ctx(s)`, `anim_oz_ctx_free(c)` | what one actor samples with, made once |
| `anim_oz_sample(ctx, clip, t, rot, pos, n) -> bool` | the clip at t (wrapped), each node's local rotation (4) and translation (3) at its file node |

A sampled rotation agrees with `anim_mix` to within 1e-4 a component (ozz keeps rotations in 16 bits).

**`animset_tick` samples through ozz.** A player's skeleton and sampling context are made when its skin is bound, a clip the first
time a player samples it (kept on the `Clip`: `oz`, `oz_n`), and every clip a frame mixes is sampled by ozz into the
per-node buffers the mixer reads. The mixing itself (fades, override and additive layers, root motion, events) is the same code
on either sampler. The Ludic sampler (`sample_rot`, `sample_pos`) is the reference and the fallback: it plays when
`anim_oz_enable(anim_st, false)`, for a clip ozz's builder refuses, and for a player whose skeleton could not be made, and it is
what `anim_play` and `anim_mix` still run. A one-shot sampled at its end is held just short of the duration (ozz wraps its time).
`ozz_parity_test` poses two skins through the same fades, layers and root motion, one sampler each: the worst component
difference is about 3.5e-5 (under the 1e-4 ozz's 16-bit rotations allow). The reference frames of an additive clip and the
root's start pose are still read with the Ludic sampler at their fixed times.

| | |
| --- | --- |
| `anim_oz_enable(anim_st, on)`, `anim_oz_enabled(anim_st)` | ozz (the default) or only the Ludic sampler |
| `animset_oz_active(pl)` | the player samples through ozz |
| `animset_release(pl)`, `anim_oz_release_clips(anim_st)` | give the native skeleton, context and clips back (an actor dropped, a rig unloaded) |

## Rules it keeps

- **Clips are named per rig.** A channel addresses its FILE's node indices, two files number their
  nodes differently, and a name already held is skipped - so one shared name would hand the
  second body the first one's skeleton. Name them `hiker_m_walk` / `hiker_f_walk`, `bear_walk`.
- **Read straight after the load.** `gltf_doc` is whichever file was parsed last, and `gltf_load`
  closes the `.bin`, which `anim_read_doc` reopens (a read through the closed handle is zeros).
- **Key from frame zero.** A clip wraps on its duration and holds below its first key, so a clip
  keyed from frame 1 holds its opening pose for 1/30 s every cycle. `anim_read_doc` prints it.
- **The math.** `skin_pose` takes a delta D in the model frame, `local = (G_p^-1 D G_p) R_rest`,
  and a channel gives the absolute local L, so D = G_p (L R_rest^-1) G_p^-1.
- The scratch is made once and grown: a call is per actor per frame.

## Animation graphs: all motion is data

**No game animates in code.** Every motion is a clip (made in Blender or taken from Mixamo) played through
a graph that is held as data: rows a game fills from `.lres` files and a studio edits. Gameplay tells the graph what
is true (a speed, a stance, a trigger) and never writes a bone. The graph is expressive enough that a game
never needs code to animate.

```ludic
def AnimSets from "assets/data/anim_sets.lres"           # the graphs
def AnimBlendSpaces from "assets/data/anim_spaces.lres"  # locomotion, aiming, steering
def AnimSkeletons from "assets/data/anim_rigs.lres"      # a rig's bone names, root and level of detail
def AnimMasks from "assets/data/anim_masks.lres"         # which bones a layer reaches
def AnimClips from "assets/data/anim_clips.lres"         # events, sync markers and root motion of clips
```

All five are open registries (`@ByKey`, prefixes `ASET_`, `ABS_`, `ASK_`, `AMASK_`, `ACLIP_`). A reference from one
row to another is the other registry's constant (`blend_space: ABS_LOCO`, `mask: AMASK_UPPER`); a reference inside
one row is a state's key (`from: "walk"`). Clip names follow the rig's prefix: `walk` is `<rig>_walk`.

### The pieces

| Registry | Row | What it holds |
| --- | --- | --- |
| `AnimSets` | `AnimSet { key, entry, params, parameters, states, transitions, layers, skeleton }` | a graph: a state machine and its layers |
| | `AnimStateDef { key, kind, choices, blend_space, sub, loop, next, blend, rate_min, rate_max, keep_phase, speed, speed_by, duration_by, sync, is_exit }` | a state: a clip (`kind: "clips"`, the first choice whose bands hold plays), a blend space (`"blend"`) or a nested graph (`"sub"`) |
| | `AnimTransition { from, to, blend, curve, curve_points, conditions, has_exit_time, exit_time, priority, interrupt, offset, to_self, when, via }` | an edge, from a state or `"*"` (any state) |
| | `AnimCondition { param, op, value }` | `op`: `gt ge lt le eq ne true false trigger` |
| | `AnimParam { key, kind, initial }` | `kind`: `float int bool trigger`; names in `params` are floats |
| | `AnimLayer { key, graph, mode, mask, weight, weight_by }` | a graph played over the base one: `override` or `additive` |
| `AnimBlendSpaces` | `AnimBlendSpace { key, dims, x_param, y_param, samples: [{ clip, x, y }], sync }` | a 1D or 2D space of clips |
| `AnimSkeletons` | `AnimSkeleton { key, model, root, prefix, bones: [{ name, node }], lod: [{ dist, every, layers, events }] }` | a rig: canonical bone names over the file's nodes, the root, how far-away actors are updated |
| `AnimMasks` | `AnimMask { key, skeleton, default, rows: [{ bone, weight, below }] }` | bones and weights; `below` takes the whole branch |
| `AnimClips` | `AnimClipInfo { key, model, clip, events, markers, root_motion, root_axes, root_turn, root_bone, ref_time }` | what a clip says about itself, by its name without the prefix; one row serves every rig that has the clip |
| | `AnimEvent { name, at, until, normalized, arg, value, min_weight }` | a keyed time; `until` after `at` makes a window |
| | `AnimMarker { name, at }` | a point of a cycle (a foot down) for sync |

### State machines

- **Transitions.** An edge with `conditions`, `has_exit_time` or `when` takes itself; the first that holds in
  priority order (higher `priority` first, then file order) is taken. An edge with none of them is a
  *request edge*: its fade applies when the code asks for `to` (`animset_request`, or `via` a one-shot). `from: "*"` leaves every state
  (not into itself unless `to_self`). Conditions of one edge are ANDed; OR is two edges. `exit_time` is how far
  through the source's clip, in cycles (`0.75` on a one-shot, `1.5` halfway into the second lap of a loop);
  for a sub state it counts while the sub graph is in an `is_exit` state. A trigger a taken edge tested is spent.
- **Fades.** `blend` seconds (0 cuts) by `curve`: `linear`, `ease`, `ease_in`, `ease_out` or `custom` (`curve_points` `t`/`v`
  as a polyline). A machine holds up to `AM_INST` (4) instances of states fading over one another, so an interrupted fade
  does not pop. `interrupt` says which transitions may cut a fade short: `dest` (default: the state being faded into may leave
  at once), `none`, `source` (transitions out of the state being left) or `both`.
- **Sub graphs.** A `sub` state runs another `AnimSet` as a machine of its own, entered at its entry, sharing the
  parameters; it starts over each time it is entered. Nested up to `AM_DEPTH` (4).
- **One-shots.** `loop: false` holds the last pose and hands on to `next` (or a transition). `offset` starts the target part way in. A state in a sync
  group (`sync: "loco"`) entered from one of the same group keeps its phase.
- **Choices** (a `clips` state) are the 1D band blend the package always had: the first whose `need` bands hold and whose clip the rig carries
  plays (`rate`, or `rate_by` a parameter over the `ground` a cycle covers, held to `rate_min .. rate_max`); a change fades over the state's `blend`,
  keeping the phase with `keep_phase`. `speed` and `speed_by` multiply any state's rate. **`duration_by`** names a parameter of seconds and plays the state's clip over that time (rate = the clip's length / the parameter, for a blend state the weighted cycle), held off while the parameter is 0 or less and multiplied with `speed` / `speed_by` after `rate_min .. rate_max`: a reload state with `duration_by: "reload_time"` and a `weapons.RELOAD_STARTED` row with `also: "reload_time"` ends with the magazine whatever the weapon's reload time, with no clip length in data. (A reciprocal `curve` on a binding was the other option: it needs the clip's length authored as a number too, which can go stale.)

### Blend spaces

`kind: "blend"` with a `blend_space`. **1D**: the two samples round the parameter are lerped, the ends held. **2D**: a Delaunay
triangulation of the sample points, made once per space and kept, and the barycentre of the triangle the point is in; a point outside goes to
its nearest edge. The weights sum to one and reproduce the point exactly, at most three clips play, and a query makes nothing
(`anim_space_weights`). Use them for locomotion (speed by direction), aiming (yaw by pitch) and driving (steer). The samples share one
phase (`sync: true`) and the cycle lasts the weighted duration, so feet stay together; with `markers` on the clips the phase runs through
their markers (segment by segment), so clips whose steps fall unevenly still put the same foot down together.

### Layers and masks

`layers` on a set: each layer is another graph on its own machine. `override` blends the pose toward the layer's, bone by bone,
by `weight x mask(bone)` (upper body shooting while the legs run); `additive` takes the layer's clips as the change away from their own
reference frame (`ref_time` in `AnimClips`, the first frame by default) and adds it over whatever plays. `weight` is a fixed number times
`weight_by`, a parameter (0..1, clamped). A mask names bones by the skeleton's canonical names (`AnimSkeleton.bones`) or by the node's own,
and `below` carries a weight down the branch. A layer at weight 0 does not run. At most five layers besides the base.

### Events

An `AnimEvent` on a clip is a fact the game drains: `footstep`, `reload`, `attach`, `hit` (a window from `at` to `until`).
Each fires exactly once per pass of its time, at the tick whose step crosses it (a time on a step's end belongs to that step), once per lap on a loop
and however many laps a long step makes; one at time 0 fires when the clip starts. `min_weight` (default 0.01) keeps a clip fading out from firing. A
window makes a `begin` and an `end` fact; a window still open when its clip is dropped gets a `cancel`, so a hit window never hangs open.
`anim_fact_count(anim_st)`, `anim_fact_at(anim_st, i)` (`AnimFact { actor, kind, name, clip, arg, value, weight, time }`, `AF_NOTIFY`, `AF_BEGIN`, `AF_END`, `AF_CANCEL`),
`anim_facts_clear(anim_st)`; the queue holds 256 and counts what did not fit (`anim_facts_lost`).

### Root motion

A clip whose `AnimClips` row says `root_motion: "extract"` reports how its root bone moved and is held in place in the pose: the translation
(`root_axes`: `xz`, or `xyz` with the height) and, with `root_turn`, the yaw. The motion is weighted by the clip's share of the pose, accumulates
across laps, and goes to the game: `anim_root_take(pl, out)` (x, y, z, yaw in radians, in the root bone's frame, before the body's heading turns it) or, with
`anim_root_port(anim_st, true)`, the `AnimRoot` port each tick: `bind AnimRoot { apply: fn move_body }` with `(actor, dx, dy, dz, dyaw_degrees)`. A clip with no row
plays as it was keyed (in place or in the world). Nothing here ever writes a transform.

### The parameter contract

Parameters are how gameplay speaks to a graph; **nothing else writes into it**. Declare them in the set (`params` for floats, `parameters` for typed ones; the graph's sub graphs and
layers share one table by name). The game keeps one `AnimPlayer` per actor and registers it once; gameplay packages' glue then calls:

| | |
| --- | --- |
| `anim_actor_add(anim_st, actor, pl)`, `anim_actor_remove(anim_st, actor)`, `anim_player_of(anim_st, actor)` | the actor number (an int the game names) and its player |
| `anim_set_param(anim_st, actor, key, v)`, `anim_set_int`, `anim_set_bool` | a value; an int rounds, a bool is on above a half; false for an actor or name the graph does not know (ignored) |
| `anim_trigger(anim_st, actor, key)`, `anim_reset_trigger` | a trigger stays on until a transition that tests it is taken |
| `anim_request(anim_st, actor, state)` | a state by name, reaching sub graphs and layers too (`layer/state`, see "A request by name" below); taken once however often it is asked |
| `anim_set_distance(anim_st, actor, metres)` | the camera's distance, for the skeleton's `lod` rows |
| `animset_param_at(pl, i, v)`, `anim_param_index(pl, key)` | the same without a lookup: ask the index once, write it every frame |

The mechanics stay apart (`uses ludic_base`), so something must turn their facts and values into these verbs. **That something is data, not code: see "Wiring gameplay to a graph" below.** A game with special needs can still call the verbs itself. The conventional names:
`speed` (m/s), `direction`/`strafe`, `grounded`, `airborne`, `crouch`, `aim` (0..1), `aim_yaw`/`aim_pitch`, `steer`, and a trigger per action (`attack`, `jump`, `hit`, `die`).
A melee attack's `clip` (`ludic.melee`: `MeleeWorld.play(actor, clip, speed)`) is `anim_trigger(actor, clip)` with a state of that name in the graph behind an any-state edge
and `anim_set_param(actor, "attack_speed", speed)` read by `speed_by`; its hit windows are the same times as the clip's `begin`/`end` facts. A vehicle seat's `pose`
(`ludic.vehicles`: the animation state the sitter plays) is `anim_request(actor, pose)`. `ludic.character`'s gait is `speed` and `grounded`.

### Wiring gameplay to a graph: `AnimBindings`

A game writes no glue. It says, as rows of a registry, which number or fact of which mechanic feeds which parameter, trigger or
state of which graph, and calls `anim_link_tick(anim_st, dt)` once a frame.

```ludic
def AnimBindings from "assets/data/anim_bindings.lres"
# each frame, after the mechanics ran and BEFORE the game drains their facts, and before animset_tick:
#   anim_link_tick(anim_st, dt)
```

```lres
speed    { set: ASET_PERSON, to: "speed", source: "crowd.speed", smooth: 0.15 }
grounded { set: ASET_PERSON, to: "grounded", source: "character.grounded" }
attack   { set: ASET_PERSON, kind: "trigger", to: "attack", source: "melee.SWING", also: "attack_speed" }
reload   { set: ASET_PERSON, kind: "trigger", to: "reload", source: "weapons.RELOAD_STARTED", also: "reload_time" }
hurt     { set: ASET_PERSON, kind: "trigger", to: "hit", source: "vitals.DAMAGED", gate: true, threshold: 5.0 }
down     { set: ASET_PERSON, kind: "request", to: "down", source: "vitals.DOWNED" }
act      { set: ASET_PERSON, kind: "request", by_name: true, source: "crowd.ACT" }
seated   { set: ASET_PERSON, kind: "request", by_name: true, source: "vehicles.seat_pose" }
jump     { set: ASET_PERSON, kind: "trigger", to: "jump", source: "character.JUMPED", actor: 1 }
```

`AnimBinding { key, set, kind, to, by_name, source, also, actor, scale, offset, curve, threshold, gate, clamp, lo, hi, smooth }`:

| Field | Meaning |
| --- | --- |
| `set` | the graph it feeds (`ASET_*`); -1 feeds every graph that declares the name |
| `kind` | `param` (writes a number; a bool or int parameter rounds as the graph says), `trigger` (sets a trigger on), `request` (asks for a state) |
| `to` | the parameter, trigger or state. With `by_name`, the word the source brings (a fact's clip, a text source's word) is the trigger or state, so one row serves every clip |
| `source` | a registered source's name, below |
| `also` | a trigger's companion: this parameter gets the fact's number (mapped) just before the trigger is set (`attack_speed`, `reload_time`) |
| `actor` | whose facts a source with no actor of its own tells (the character is one body: its facts say -1) |
| `scale`, `offset`, `curve`, `threshold`, `clamp` / `lo` / `hi` | the number becomes `number * scale + offset`, then the curve (`linear`, `abs`, `square`, `sqrt`, `step`: 1 from `threshold` up else 0, `invert`: 1 - x), then the clamp |
| `gate` | a fact fires only when its mapped number reaches `threshold` (a landing hard enough, a blow big enough) |
| `smooth` | seconds: a parameter follows a value source with this time constant, from where it was (the first sample takes the value) |

**Sources** are named by the package that knows them. A fact source fires once per fact waiting in the mechanic's queue when the link
ticks (the queue is read, never drained: the game's own route still drains it; tick the link once a frame before that drain). A value
source is asked of every actor whose graph the row feeds. A text source is a word that is requested by name when it changes to a new
one. A `trigger` or `request` row on a value source fires when the mapped value rises through `threshold`.

| Package | Fact sources (the word, the number) | Value sources | Text |
| --- | --- | --- | --- |
| `ludic.melee` | `melee.SWING` (attack clip, playing speed), `ENDED`, `STAGGERED` (-, seconds), `RECOVERED`, `GUARD_UP`, `GUARD_DOWN`, `HIT_TAKEN` (-, damage; about the victim) | `melee.attacking`, `blocking`, `staggered` (0/1), `progress` | |
| `ludic.weapons` | `weapons.FIRED`, `RELOAD_STARTED`, `RELOADED`, `EMPTY`, `EQUIPPED`, `HOLSTERED`, `CHARGING` (the fact's clip, seconds the act takes) | `weapons.reloading` (0/1), `ads`, `charge`, `recoil_pitch`, `armed` (0/1), `held_kind` (class row order + 1, 0 unarmed) | `weapons.hold` (the held class's `hold` name) |
| `ludic.vitals` | `vitals.DAMAGED` (-, amount), `DOWNED`, `DIED`, `REVIVED`, `RESPAWNED` (the class's clip, amount) | `vitals.health` (0..1), `downed`, `dead` (0/1) | |
| `ludic.crowd` | `crowd.ACT` (anim state key, act), `REACTED` (-, PedReact), `ATTACK` | `crowd.speed` (m/s), `turn` (rad/s), `state` (PedReact), `variant` (0..1, fixed per ped) | `crowd.act_key` |
| `ludic.character` | `character.JUMPED`, `LANDED` (-, landing speed), `FOOTFALL`, `STARTED_SWIMMING`, `LEFT_WATER` | `character.speed`, `moving`, `run`, `direction` (-1..1 half turns, positive left), `crouch` (0..1), `sprint` (0..1), `gait` (0 still, 1 walk, 2 run, 3 sprint), `airborne`, `grounded`, `sitting`, `swimming`, `diving`, `vy`, `depth`, `landing` | |
| `ludic.cars` | `cars.BOARDING`, `SEATED`, `EXITED`, `EJECTED`, `DRAGGED` (the seat's graph state, the seat) | `cars.riding`, `driver`, `passenger`, `door` (0/1), `speed` (m/s), `steer` (-1..1) | `cars.seat_state` |
| `ludic.vehicles` | `vehicles.MOUNTED` (seat pose), `DISMOUNTED` | `vehicles.speed`, `riding` | `vehicles.seat_pose` |

Actors are the game's numbers, the ones given to `anim_actor_add`: the fighter, shooter, vital or ped the mechanic's own verbs name
(a crowd ped is its uid; a vehicle's rider is the player it names).

**A request by name reaches every graph of the player, not only the base one** (`anim_request`, a `request` row, `crowd.act_key`). Where a name is looked for:

| Name | Reaches |
| --- | --- |
| `state` | the base graph's own states first; else the first graph that has one, in this order: the sub graphs (depth first, as the base graph's states list them), then each layer's graph (declaration order) with its sub graphs |
| `layer/state` | the layer whose `key` is `layer` (a key of the base graph's `layers`), then that graph's own state |
| `sub/state` | the `sub` state whose key is `sub`, then a state of the graph it runs. Segments chain: `armed/aim/raise` is a layer, a sub state in it, a state there |

A plain name two graphs share (`raise` in two layers) goes to the first; say `layer/state` to choose. A request to a state of a sub graph also asks every graph above it to be in the sub state that runs it (or the sub graph would not run), and the sub graph then starts at the requested state instead of its entry; a layer's graph runs all the time and needs nothing above it. Taken once however often it is asked, per graph. A name nothing has is ignored (`anim_request` answers false), and `anim_link_validate` reports `anim.link_unknown_state` for a `request` row whose `to` no graph, sub graph or layer of its set has by this rule (a qualified name must match exactly). Parameters and triggers were always shared by name across all of them.

**Adding a source (a package, a car, anything).** A mechanic declares what it can tell in a file of its own, depending on `ludic.base` only,
and this package imports no mechanic. `ludic.base`'s `SignalSources` is an open registry (`SignalSource { name, kind, about, unit, arg, count, read, get, say }`):

```ludic
function car__count(cars_st: CarsState) -> int { return len(car_facts(cars_st).items) }
function car__read(cars_st: CarsState, i: int, arg: int, out: SigFact) -> bool {     # fact i, if it is of kind `arg`
  let f = car_facts(cars_st).items[i]
  if f.what != arg { return false }
  out.actor = f.driver
  out.value = f.speed
  out.name = ""
  return true
}
function car__get(cars_st: CarsState, actor: int, arg: int) -> float { return car_steer_of(cars_st, actor) }   # a value per actor
def SignalSources car_crash  { name: "cars.CRASH", kind: "fact", about: "a car hit something (value: speed)", unit: "m/s", arg: CAR_CRASH, count: fn car__count, read: fn car__read }
def SignalSources car_steer  { name: "cars.steer", kind: "value", about: "steering", unit: "-1..1", arg: 0, get: fn car__get }
```

The functions take the mechanic's own state (supplied, like a system's tick) and allocate nothing. The mechanic's README names its sources; a
new fact kind is one `def`. A studio lists them through the dev verb `signal_source at:int` (`ok <count> "<name>" "<kind>" "<unit>" "<about>"`,
paged from 0 to count), or by reading `SignalSources`.

**Validation.** `anim_link_validate() -> []AnimProblem` checks every row by its key (`bindings/<key>`): `anim.link_unknown_source` (names the
registered sources of that mechanic), `anim.link_source_broken` (a registered source missing what its kind needs),
`anim.link_source_kind` (a text source on anything but a request, a word from a value source, a parameter named by a word),
`anim.link_no_target`, `anim.link_unknown_param`, `anim.link_unknown_state`, `anim.link_unknown_set`, `anim.link_trigger_kind` and
`anim.link_param_kind` (a trigger on a plain parameter and the reverse), `anim.link_smooth`, `anim.link_clamp`, `anim.link_param_conflict` (two rows
writing one parameter of one graph), and the `@OneOf` hints refuse an unknown `kind` or `curve` at compile time. At run time a row with a
source that is unknown or broken, or a target the graph does not declare, does nothing.

**Cost.** A tick allocates nothing: each row's source and each player's parameter index are found once, and what a row last sent is
kept in tables made when the player is first seen (`link_test` holds the heap still over thousands of ticks).

### Skeletons, validation

`AnimSkeletons` rows bind a rig: its file (`model`), the `root` bone, the clip `prefix`, `bones` (canonical name to the file's node: `hand_r` is `mixamorig:RightHand`) and `lod`.
Retargeting is offline (Blender); the bone map makes masks and events portable across rigs.

`anim_validate(anim_st, set, rig, sk) -> []AnimProblem` (`AnimProblem { severity, code, where, what }`, `AP_ERROR`, `AP_WARNING`) names what a graph gets wrong, by the row. Without the rig's clips
loaded (`sk` and the clip table may be empty) it checks what the data alone says. Codes: `anim.unknown_clip`, `anim.clip_bone_missing`, `anim.unknown_param`, `anim.unreachable_state`,
`anim.entry_unknown`, `anim.duplicate_state`, `anim.no_states`, `anim.no_clips`, `anim.no_default_choice`, `anim.transition_unknown_state`, `anim.exit_time_range`, `anim.curve_points`,
`anim.negative_blend`, `anim.condition_kind`, `anim.param_kind_clash`, `anim.sync_single`, `anim.sub_missing`, `anim.sub_cycle`, `anim.space_missing`, `anim.space_empty`,
`anim.space_degenerate`, `anim.space_duplicate_point`, `anim.space_sliver`, `anim.layer_graph_missing`, `anim.mask_missing`, `anim.mask_bone_missing`, `anim.mask_weight`, `anim.mask_empty`,
`anim.additive_unmasked`, `anim.too_many_layers`, `anim.skeleton_bone_duplicate`, `anim.skeleton_bone_missing`, `anim.skeleton_root_missing`, `anim.lod_unsorted`,
`anim.event_out_of_range`, `anim.window_inverted`, `anim.markers_unsorted`. Rows of `AnimBindings` have their own (see above: `anim.link_*`).

### The player

```ludic
let pl = new AnimPlayer
animset_bind(anim_st, pl, ASET_PERSON, "hiker_m")      # or animset_bind_skel(anim_st, pl, ASET_PERSON, ASK_HIKER): the skeleton's prefix, bones and lod
anim_actor_add(anim_st, 7, pl)
anim_set_param(anim_st, 7, "speed", 3.2)
animset_tick(anim_st, pl, sk, dt)                      # into the skin
```

A player is ready once the entry state's clips are found (call `animset_bind` again until the model has loaded and read its clips). The pieces: `animset_state(pl)`,
`animset_machine_state(pl, m)` (a sub graph's or layer's state), `animset_clip`, `animset_choice`, `animset_rate`, `animset_can(pl, state)`.

**Performance.** A tick makes nothing: the machines, clip slots, parameter table, masks and triangulations are made when the player is bound (and the scratch once, grown to the largest skeleton),
and `actors_test` holds the heap still over thousands of ticks through sub graphs, fades, blend states, layers and events. `lod` rows on the skeleton pick, by the distance the game says, how often a
far actor updates (`every`: one tick in that many, by the time the skipped ones left, spread by actor number), how many layers it plays and whether it fires events.

## In the studio

`studio.lres` beside `package.ludic` tells Ludic Studio how to draw `AnimSets` (key `anims`: states as nodes, transitions as edges, choices with their need bands and rates), and names
what a whole graph editor needs (state kinds, conditions, fades, parameters, layers, blend spaces, masks, skeletons, clip events and root motion). It counts only in a game that uses
this package; the compiler never reads it. `anim_bindings` (table `AnimBindings`) is the wiring table: one row per binding, its `source` a pick from the registered
`SignalSources` (`source_table`, `source_name`, `source_kind`, `source_about`), its `to` a parameter of the row's graph (`param_table: "AnimSets"`, `set_field: "set"`) or, for a request, one of its states. The rig is the package's own (a set's `skeleton` row in `AnimSkeletons`: `model`, `root`, `prefix`; clips are `<prefix>_<clip>`), but the studio's rig binding cannot yet follow a reference from a graph to its skeleton, so a game that wants its clips played in the graph writes an `anims` entry of its own with `rig_table: "AnimSkeletons"`, `rig_file: "model"` and `clip_pattern: "{prefix}_{clip}"` (right for one skeleton), which replaces this one.

## Tests

```bash
ludic test packages/ludic.anim
```

On a four-bone skin made from a glTF document with no GPU, with clips made by hand (`tests/support/rig.ludic`): sampling, wrapping and the cross-fade (`anim_test`); an animation set
written before graphs (`animset_test`, `sets.lres`); state machines - conditions of every kind, exit time, any-state edges, priority, fade curves, interrupts and nested graphs
(`graph_test`); blend spaces, 1D and 2D exact, sync phase and markers (`blend_test`); layers, masks and the level of detail (`layers_test`); events firing once at the
right tick, on a loop, windows and cancels (`events_test`); root motion accumulation and the port (`root_test`); every validation finding (`validate_test`); and the actor verbs with the
zero-allocation check (`actors_test`). `ozz_test` runs the native library, and `ozz_parity_test` poses two skins through the same graphs with ozz and with the
Ludic sampler. The wiring: `request_test` (requests reaching sub graphs and layers, `layer/state`, the graph above a sub graph following, validation by the same rule, `duration_by`), `link_test` (a toy mechanic's declared sources, facts firing once, values through scale, curve, clamp and smoothing, requests by name, edges, the heap held still),
`link_real_test` (the adapters of melee, weapons, vitals, crowd, character and vehicles against their real records and states) and `link_validate_test` (every `anim.link_*` finding).

## A figure placed again and again (a crowd's peds)

`gltf_load` reads the file, parses the document and builds the skin, and prints two lines: once per model, never once per figure.
`anim_model_load` loads a node once (its clips read the first time) and answers a repeat ask with a lookup. The per-figure parts
(an `Actor`, a skin of its own, an `AnimPlayer`) come from a pool made before play, so a spawn reads, parses, prints and allocates nothing.

| | |
| --- | --- |
| `anim_model_load(anim_st, render3d_st, dir, file, node) -> Model` | the model of a node, once per (dir, file, node); the first ask also reads its clips |
| `anim_actor_pool(anim_st, model, set, skel, n)` | before play: `n` figures made and waiting, and the actor table sized for them |
| `anim_actor_spawn(anim_st, render3d_st, model, set, skel, who) -> Actor` | a pooled figure at rest, filed under `who`; past the pool it makes one more and counts it |
| `anim_actor_despawn(anim_st, render3d_st, actor, who)` | its actor, player and skin go back |
| `anim_pool_misses(anim_st)`, `anim_pool_size(anim_st)` | spawns the pool could not serve; figures made |
| `anim_actor_reserve(anim_st, n)` | the actor table sized for `n` at once (the pool does it); adding and removing actors then allocates nothing |
| `animset_restart(anim_st, pl)` | a player back at its graph's start |

```ludic
let m = anim_model_load(anim_st, render3d_st, "assets/people", "person.glb", "person")   # at load
anim_actor_pool(anim_st, m, SET_PED, SKEL_PED, 600)                                       # the most peds alive
let a = anim_actor_spawn(anim_st, render3d_st, m, SET_PED, SKEL_PED, uid)                 # in play: no file, no alloc
a.scale = 1.0
anim_actor_despawn(anim_st, render3d_st, a, uid)                                          # when the ped is gone
```
