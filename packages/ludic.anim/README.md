# ludic.anim

The animation clips an animator keyed into a glTF, played on a render3d `Skin` and cross-faded two
at a time. `ludic.render3d` parses no animations and offers a pose api (`skin_set_quat`,
`skin_set_offset`, `skin_pose`) rather than a player, so the sampler lives here. Uses
`ludic_render3d` and nothing else: it reads the document `gltf_load` just parsed and writes a
Skin's pose. It asks the game nothing, so it has no port.

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

## Animation sets

Which clip plays when, as data: `AnimSets` is an open registry (`@ByKey`, `ASET_*`) a game fills with
`def AnimSets from "assets/data/anim_sets.lres"`. A set is a graph - states (nodes) each with an
ordered list of choices, the first whose `need` bands all hold and whose clip the rig carries playing
(`rate`, or `rate_by` a parameter over the `ground` a cycle covers, held to `rate_min` / `rate_max`),
and transitions (from a state or `"*"`, with a fade; with `@frame when: fn() -> bool`, taken on their
own the frame it answers true). The code binds an `AnimPlayer` to a set and a rig
(`animset_bind`), sets parameters (`animset_param`), asks for a state (`animset_request`, taken once
however often it is asked) and ticks it into a skin (`animset_tick`). A one-shot (`loop: false`)
holds its last pose and hands on to `next`. Clip names are made once per rig; a tick makes nothing.

## Tests

```bash
ludic test packages/ludic.anim
```

A two-bone skin made from a glTF document with no GPU: sampling, wrapping, the cross-fade,
translations off by default, and clips read out of a `.bin` written to the temp directory. And an
animation set on a rig of hand-made clips (`animset_test`, `sets.lres`): need bands, the rate clamp,
a one-shot's `next`, a `when` edge, and a request taken once.
