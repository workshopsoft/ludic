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
`anim_play` still runs the Ludic sampler until the callers move (Maroon Lake's phase 19).

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
| | `AnimStateDef { key, kind, choices, blend_space, sub, loop, next, blend, rate_min, rate_max, keep_phase, speed, speed_by, sync, is_exit }` | a state: a clip (`kind: "clips"`, the first choice whose bands hold plays), a blend space (`"blend"`) or a nested graph (`"sub"`) |
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
  keeping the phase with `keep_phase`. `speed` and `speed_by` multiply any state's rate.

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
| `anim_request(anim_st, actor, state)` | a state by name, for graphs that stay simple; taken once however often it is asked |
| `anim_set_distance(anim_st, actor, metres)` | the camera's distance, for the skeleton's `lod` rows |
| `animset_param_at(pl, i, v)`, `anim_param_index(pl, key)` | the same without a lookup: ask the index once, write it every frame |

The mechanics stay apart (`uses ludic_base`), so the route is the game's: it reads a mechanic's ports and facts and turns them into these verbs. The conventional names:
`speed` (m/s), `direction`/`strafe`, `grounded`, `airborne`, `crouch`, `aim` (0..1), `aim_yaw`/`aim_pitch`, `steer`, and a trigger per action (`attack`, `jump`, `hit`, `die`).
A melee attack's `clip` (`ludic.melee`: `MeleeWorld.play(actor, clip, speed)`) is `anim_trigger(actor, clip)` with a state of that name in the graph behind an any-state edge
and `anim_set_param(actor, "attack_speed", speed)` read by `speed_by`; its hit windows are the same times as the clip's `begin`/`end` facts. A vehicle seat's `pose`
(`ludic.vehicles`: the animation state the sitter plays) is `anim_request(actor, pose)`. `ludic.character`'s gait is `speed` and `grounded`.

### Skeletons, validation

`AnimSkeletons` rows bind a rig: its file (`model`), the `root` bone, the clip `prefix`, `bones` (canonical name to the file's node: `hand_r` is `mixamorig:RightHand`) and `lod`.
Retargeting is offline (Blender); the bone map makes masks and events portable across rigs.

`anim_validate(anim_st, set, rig, sk) -> []AnimProblem` (`AnimProblem { severity, code, where, what }`, `AP_ERROR`, `AP_WARNING`) names what a graph gets wrong, by the row. Without the rig's clips
loaded (`sk` and the clip table may be empty) it checks what the data alone says. Codes: `anim.unknown_clip`, `anim.clip_bone_missing`, `anim.unknown_param`, `anim.unreachable_state`,
`anim.entry_unknown`, `anim.duplicate_state`, `anim.no_states`, `anim.no_clips`, `anim.no_default_choice`, `anim.transition_unknown_state`, `anim.exit_time_range`, `anim.curve_points`,
`anim.negative_blend`, `anim.condition_kind`, `anim.param_kind_clash`, `anim.sync_single`, `anim.sub_missing`, `anim.sub_cycle`, `anim.space_missing`, `anim.space_empty`,
`anim.space_degenerate`, `anim.space_duplicate_point`, `anim.space_sliver`, `anim.layer_graph_missing`, `anim.mask_missing`, `anim.mask_bone_missing`, `anim.mask_weight`, `anim.mask_empty`,
`anim.additive_unmasked`, `anim.too_many_layers`, `anim.skeleton_bone_duplicate`, `anim.skeleton_bone_missing`, `anim.skeleton_root_missing`, `anim.lod_unsorted`,
`anim.event_out_of_range`, `anim.window_inverted`, `anim.markers_unsorted`.

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
this package; the compiler never reads it. A rig is the game's (its own table of files, nodes and clip prefix), so a game that wants its clips played in the graph writes an
`anims` entry of its own with `rig_table`, `rig_file` and `rig_node`, which replaces this one.

## Tests

```bash
ludic test packages/ludic.anim
```

On a four-bone skin made from a glTF document with no GPU, with clips made by hand (`tests/support/rig.ludic`): sampling, wrapping and the cross-fade (`anim_test`); an animation set
written before graphs (`animset_test`, `sets.lres`); state machines - conditions of every kind, exit time, any-state edges, priority, fade curves, interrupts and nested graphs
(`graph_test`); blend spaces, 1D and 2D exact, sync phase and markers (`blend_test`); layers, masks and the level of detail (`layers_test`); events firing once at the
right tick, on a loop, windows and cancels (`events_test`); root motion accumulation and the port (`root_test`); every validation finding (`validate_test`); and the actor verbs with the
zero-allocation check (`actors_test`). `ozz_test` runs the native library.
