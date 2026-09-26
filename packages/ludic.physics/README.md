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

| | |
| --- | --- |
| `phys_open(st, max_bodies, threads) -> bool`, `phys_close(st)`, `phys_is_open(st)` | a world, and everything in it let go |
| `phys_box`, `phys_sphere`, `phys_capsule`, `phys_cylinder`, `phys_dome(r, h)`, `phys_offset(shape, x, y, z, yaw)` | shapes, each an int (`-1` refused); a dome is a boulder standing on its origin |
| `phys_heightfield(st, h, n, ox, oz, cell)`, `phys_mesh(st, v, nv, tri, nt)` | the ground (`PHYS_HOLE` is none) and a dock or cabin |
| `phys_ground_add`, `phys_static_add`, `phys_kinematic_add`, `phys_body_add(..., mass)` | bodies: the ground, still things, what the game moves (the player), what falls and floats |
| `phys_settle(st)` | after adding many still things, before the first query |
| `phys_remove(st, id)`, `phys_count(st)` | gone for good |
| `phys_pose(st, id) -> PhysPose`, `phys_yaw_of(p)` | position, rotation, velocity |
| `phys_place`, `phys_impulse`, `phys_set_velocity`, `phys_set_kinematic_target`, `phys_awake` | moving a body |
| `phys_ray(st, o, d, mask) -> PhysHit` | the first thing along a ray |
| `phys_top_at(st, x, z, r, from_y, depth, mask) -> float` | what a foot would land on (`CharacterGround.top_at`), `PHYS_NONE` if nothing |
| `phys_push(st, x, z, r, y0, y1, mask) -> PhysPush` | the move that stands an upright body clear (`CharacterGround.push`) |
| `phys_resolve(st, x, z, r, y0, y1, mask) -> bool`, `phys_resolved_x` / `_z` | pushed clear in two passes, the place kept (`CharacterGround.push`, `pushed_x` / `_z`); a contact more up than across is ground under the feet, not a wall |
| `phys_step_top(st, x, z, r, feet, reach, mask) -> float` | the highest top a foot could step up to, anything taller than `feet + reach` left out as a wall |
| `phys_overlap(st, x, y, z, r, mask) -> []int` | the bodies a ball touches |
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
