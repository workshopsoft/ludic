# ludic.physics

Rigid bodies, still shapes that can be removed, queries and buoyancy, over
[Jolt Physics](https://github.com/jrouwe/JoltPhysics) (MIT) built here from a pinned tag
(phase 16). Uses `ludic.base` and nothing else.

```ludic
import "ludic.physics"
```

## The rules it keeps

- **A package with a native library** (phase 15): `native/build.sh` fetches Jolt v5.6.0, checks
  its SHA-256, and builds it with the shim `native/shim/jph_shim.cpp` into `lib/<target>/`
  (`libludicjolt.dylib`, `ludicjolt.dll`). The shim keeps the rules in
  [packages/README.md](../README.md#native-libraries): no callback into Ludic, contacts recorded
  during the step and drained after it, Jolt's job threads inside C.
- **Deterministic across machines**: `JPH_CROSS_PLATFORM_DETERMINISTIC` and no floating point
  contraction, so the Mac and the PC agree in co-op and a run repeats to the bit (a test holds it).
- **Fixed steps**: `phys_tick` runs as many 1/60 s steps as the frame's time holds, at most four -
  frame rate never changes the rules, and a stall is not replayed.
- **It saves nothing.** A thing at rest is saved by the Thing's owner; the world is rebuilt on
  load and on a map swap (`phys_close`, `phys_open`).
- **A shape and the world are handles it keeps**; a game names a shape and a body by an int.
- **Removal is real**: `phys_remove` takes a body out of the world - no parking it far away.

## The API

A query fills a record the caller keeps (`p`, `h`) and allocates nothing: it is asked every frame, and
Ludic gives no allocation back.

| | |
| --- | --- |
| `phys_open(st, max_bodies, threads) -> bool`, `phys_close(st)`, `phys_is_open(st)` | a world, and everything in it let go |
| `phys_box`, `phys_sphere`, `phys_capsule`, `phys_cylinder`, `phys_dome(r, h)`, `phys_convex(points, n)`, `phys_scaled(shape, k)`, `phys_offset(shape, x, y, z, yaw)` | shapes, each an int (`-1` refused); a dome is a boulder standing on its origin; a convex hull of n points (x, y, z) is a rock's own shape, made once and scaled for every rock of that shape; a body's yaw turns it as a renderer turns an instance (x' = cos x + sin z, z' = -sin x + cos z) |
| `ColliderShapes`, `phys_shape_of(st, row)`, `phys_shape_row(st, i)` | still shapes as rows of an open registry (`def ColliderShapes from "colliders.lres"`): a `cylinder`, `box`, `capsule`, `sphere` or `dome` standing on its origin by its measures, `lift`, `x`, `z` and `yaw` moving it; a `mesh` or `none` row is `-1` (only the game's loader can read a model's triangles). The code's own `phys_box` ... are unchanged |
| `phys_heightfield(st, h, n, ox, oz, cell)`, `phys_mesh(st, v, nv, tri, nt)` | the ground (`PHYS_HOLE` is none; ludic.render3d's `tmap_field` fills `h` from a map's height tiles) and a dock or cabin |
| `phys_prism(st, pts, n, y0, y1)` | a building's piece: the convex polygon of n points (x, z pairs, world metres) stood from y0 to y1, for a body at the origin; ludic.city's baked colliders arrive in this form (`CityPiece`) |
| `phys_ground_add`, `phys_static_add`, `phys_kinematic_add`, `phys_body_add(..., mass)` | bodies: the ground, still things, what the game moves (the player), what falls and floats |
| `phys_settle(st)` | after adding many still things, before the first query |
| `phys_remove(st, id)`, `phys_count(st)` | gone for good |
| `phys_pose(st, id, p) -> bool`, `phys_yaw_of(p)` | position, rotation, velocity |
| `phys_place`, `phys_impulse`, `phys_set_velocity`, `phys_set_kinematic_target`, `phys_awake` | moving a body |
| `phys_ccd(st, id, on) -> bool`, `phys_is_ccd(st, id) -> bool` | continuous collision detection for one dynamic body (Jolt's `LinearCast` motion quality): its shape is swept over each step and stopped at what it would skip - a car at 60 m/s moves a metre a step, more than a wall is thick. Off by default (a sweep costs; turn it on for what is fast: a car, a thrown thing). A still or kinematic body, a removed id or no world: `false` |
| `phys_ray(st, o, d, mask, h) -> bool` | the first thing along a ray |
| `phys_top_at(st, x, z, r, from_y, depth, mask) -> float` | what a foot would land on (`CharacterGround.top_at`), `PHYS_NONE` if nothing |
| `phys_push(st, x, z, r, y0, y1, mask, p) -> int` | the move that stands an upright body clear (`CharacterGround.push`) |
| `phys_resolve(st, x, z, r, y0, y1, mask) -> bool`, `phys_resolved_x` / `_z` | pushed clear in two passes, the place kept (`CharacterGround.push`, `pushed_x` / `_z`); a thing wholly under the feet or over the head is not in the way |
| `phys_step_top(st, x, z, r, feet, reach, mask) -> float` | the highest top a foot could step up to, anything taller than `feet + reach` left out as a wall |
| `phys_overlap(st, x, y, z, r, mask) -> int`, `phys_overlap_id(st, i)` | how many bodies a ball touches, and each one |
| `phys_walker_add(st, r, h, x, y, z, max_slope, mass)`, `phys_walker_step(st, id, dt, vx, vz, jump) -> ground`, `phys_walker_pose(st, id, p) -> bool`, `phys_walker_place`, `phys_walker_limits(step_up, stick)`, `phys_walker_remove` | a walking body (Jolt's CharacterVirtual): gravity, landing, steps, slopes, following the ground down; it shoves dynamic things and rays find its `body` |
| `phys_force`, `phys_torque`, `phys_angular_impulse`, `phys_spin_y`, `phys_set_pose(st, id, pose)` | an oar's stroke and a turn; a guest's copy put where the host said |
| `phys_float(st, id, buoyancy, linear_drag, angular_drag)`, `phys_sink`, `phys_floating` | a body buoyed each step against `PhysWater` and carried by its current |
| `phys_ragdef_begin(st, n)`, `phys_ragdef_part(st, i, parent, f)`, `phys_ragdef_make(st) -> def` | a ragdoll's definition (Jolt's RagdollSettings: a capsule a part, a swing-twist constraint to its parent, a bend for a knee or an elbow; `PHYS_RAG_PART` floats a part, ragdoll.ludic says which); it outlives a world |
| `phys_ragdoll_add(st, def, pose, vel) -> id`, `phys_ragdoll_read(st, id, out) -> awake`, `phys_ragdoll_impulse`, `phys_ragdoll_body`, `phys_ragdoll_parts`, `phys_ragdoll_remove` | a ragdoll in the world from a pose (each part's body at its joint, so it reads back as bones); its parts sweep (CCD), touching parts never collide; `false` from the read when every part sleeps |
| `phys_sensor(st, id, on) -> bool` | a body that is met (its contacts are facts) but pushes nothing; no query finds a sensor |
| `phys_step_us(st)` | the last step's time in Jolt, microseconds |
| `phys_facts(st)` | `PhysFact`: `PHYS_HIT` (two bodies met at `ph_hard` m/s or more), `PHYS_SPLASH` (a floating body reached water) |
| `phys_tick`, `phys_advance(st, dt) -> steps`, `phys_step`, `phys_system()` | the system, in `PH_SIMULATE` |
| `phys_config(st, step, sub, hard)`, `phys_gravity(st, y)` | the numbers |

A query's mask is `PHYS_M_GROUND`, `PHYS_M_STATIC`, `PHYS_M_MOVING`, or `PHYS_M_SOLID` /
`PHYS_M_ALL` - the body's own questions leave the ground out, because `hk_ground` stays the pure
ground query.

## The port

`PhysWater { height(x, z), current_x(x, z), current_z(x, z) }` - the surface under a point
(`PHYS_NONE` where there is no water) and the current there. Unbound, there is no water. The game
binds it to the same function its water is drawn with, so a boat never floats on a different wave
from the one on screen.

## Tests

`ludic test packages/ludic.physics` runs the real library: a box onto a heightfield and a ray to
it, still things removed, a boulder's top, a push out of a post, a crate floating level and
drifting, hard and soft landings, a kinematic shove, fixed steps, and a pile run twice to the bit;
and `tests/ccd_test.ludic` (Jolt 5.6.0, 60 Hz): at 60 m/s a ball goes through a thin wall without `phys_ccd` and stops at it with it; a car-sized box stops at the wall nose first, broadside and at an angle; a fast fall stays above the ground; a body at rest is as still with it; a run repeats to the bit; and `tests/ragdoll_test.ludic`: a ragdoll thrown at 15 m/s onto a mesh floor rests on it, never under it, its joints held, and a sensor is met by a car that drives through it unslowed and is found by no ray.

**Cars: set `phys_ccd` on both bodies.** Measured, two 4.4 m cars head-on at 55 m/s each: without it they swap places and drive on (centre gap -271 m after 3 s); with it on one car only they do not swap but overlap 0.64 m (gap 3.76 of 4.40); with it on both they overlap 0.02 m (gap 4.38). Jolt sweeps a `LinearCast` body against bodies that are not `LinearCast` themselves, so a pair of fast bodies each needs it. Against a standing car or a thin barrier the car's own flag is enough (gaps 4.38 and 2.23 of 4.40 and 2.25, the target's flag changes nothing; without it the nose goes 0.8 m into a 0.1 m barrier). A car is 4.4 m long, so unlike a ball it cannot skip a wall whole at 1 m a step, but without the sweep it ends each step deep inside it.
