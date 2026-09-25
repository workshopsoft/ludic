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

## Tests

```bash
ludic test packages/ludic.anim
```

A two-bone skin made from a glTF document with no GPU: sampling, wrapping, the cross-fade,
translations off by default, and clips read out of a `.bin` written to the temp directory.
