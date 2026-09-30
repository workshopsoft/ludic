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
| `phys_heightfield(st, h, n, ox, oz, cell)`, `phys_mesh(st, v, nv, tri, nt)` | the ground (`PHYS_HOLE` is none) and a dock or cabin |
| `phys_ground_add`, `phys_static_add`, `phys_kinematic_add`, `phys_body_add(..., mass)` | bodies: the ground, still things, what the game moves (the player), what falls and floats |
| `phys_settle(st)` | after adding many still things, before the first query |
| `phys_remove(st, id)`, `phys_count(st)` | gone for good |
| `phys_pose(st, id, p) -> bool`, `phys_yaw_of(p)` | position, rotation, velocity |
| `phys_place`, `phys_impulse`, `phys_set_velocity`, `phys_set_kinematic_target`, `phys_awake` | moving a body |
| `phys_ray(st, o, d, mask, h) -> bool` | the first thing along a ray |
| `phys_top_at(st, x, z, r, from_y, depth, mask) -> float` | what a foot would land on (`CharacterGround.top_at`), `PHYS_NONE` if nothing |
| `phys_push(st, x, z, r, y0, y1, mask, p) -> int` | the move that stands an upright body clear (`CharacterGround.push`) |
| `phys_resolve(st, x, z, r, y0, y1, mask) -> bool`, `phys_resolved_x` / `_z` | pushed clear in two passes, the place kept (`CharacterGround.push`, `pushed_x` / `_z`); a thing wholly under the feet or over the head is not in the way |
| `phys_step_top(st, x, z, r, feet, reach, mask) -> float` | the highest top a foot could step up to, anything taller than `feet + reach` left out as a wall |
| `phys_overlap(st, x, y, z, r, mask) -> int`, `phys_overlap_id(st, i)` | how many bodies a ball touches, and each one |
| `phys_walker_add(st, r, h, x, y, z, max_slope, mass)`, `phys_walker_step(st, id, dt, vx, vz, jump) -> ground`, `phys_walker_pose(st, id, p) -> bool`, `phys_walker_place`, `phys_walker_limits(step_up, stick)`, `phys_walker_remove` | a walking body (Jolt's CharacterVirtual): gravity, landing, steps, slopes, following the ground down; it shoves dynamic things and rays find its `body` |
| `phys_force`, `phys_torque`, `phys_angular_impulse`, `phys_spin_y`, `phys_set_pose(st, id, pose)` | an oar's stroke and a turn; a guest's copy put where the host said |
| `phys_float(st, id, buoyancy, linear_drag, angular_drag)`, `phys_sink`, `phys_floating` | a body buoyed each step against `PhysWater` and carried by its current |
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
drifting, hard and soft landings, a kinematic shove, fixed steps, and a pile run twice to the bit.
