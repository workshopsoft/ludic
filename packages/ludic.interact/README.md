# ludic.interact

Interaction points: where a body meets an object. A bench's seats, a boat's helm, a car's door handle, a gun's grip. Every system
uses the same rows, the same solve and the same markers.

## What it adopts

- **Unreal sockets** (`UStaticMeshSocket`/`USkeletalMeshSocket`: a name, a relative location, rotation and scale on a mesh or bone;
  FBX import turns empties named `SOCKET_<name>` into sockets). Adopted: a named point in the object's frame with a rotation, and the
  `SOCKET_` empty-node convention for the measuring tool.
- **Unreal Smart Objects** (`FSmartObjectSlotDefinition`: slots with an offset and rotation per definition, and
  `USmartObjectSlotEntranceAnnotation` entry points where a user stands to enter or exit a slot). Adopted: one definition per object
  *type*, several slots (`seat_0`, `seat_1`), and entrance points beside them (`stand_0`).
- **Second Life sit targets** (`llSitTarget(offset, rot)`: the avatar's root is placed so that its sit offset lands at the target in
  the prim's frame). Adopted: the solve moves the root only, never the bones.
- **Unreal Motion Warping** (`UMotionWarpingComponent`, `AnimNotifyState_MotionWarping`: a clip's root motion is carried onto a warp
  target over a window of the clip, not snapped). Adopted: `interact_warp` gives the window's weight.
- GTA's door dummies (named points on a vehicle model where a ped's hand and feet go) are the same thing as sockets here.

## The format

One row per point, keyed `<obj>__<name>` (a row key cannot hold a dot; lookups go by the obj and name fields, interact_find), in a game's file (`def InteractPoints from "data/interact_points.lres"`):

```
kit_bench.seat_0 { obj: "kit_bench", name: "seat_0", part: "pelvis", x: -0.35, y: 0.481, z: 0.085, yaw: 0.0, radius: 0.25 }
```

| field | meaning |
|---|---|
| `obj` | the object type: a kit, a car model, a weapon |
| `name` | the point: `seat_N`, `stand_N`, `helm`, `wheel_l`, `wheel_r`, `throttle`, `board`, `leave`, `handle`, `enter`, `exit`, `shifter`, `handbrake`, `grip`, `support`, `mag`, `sight` |
| `part` | the body part that goes on it: `root`, `pelvis`, `feet`, `hand_r`, `hand_l`, `eye`, `head` |
| `x y z` | metres in the object's frame: +z forward (the way a user faces), +x the facing's right, +y up |
| `yaw pitch roll` | degrees: the way the body (or the hand) faces there; yaw alone for standing and sitting |
| `ax ay az` | an optional axis or direction: a wheel's spin axis, a door's swing, a barrel |
| `radius` | how near counts as on it: a reach, a trigger, a seat's half width |

Naming: a seat's index matches its entrance (`seat_1` is entered from `stand_1`). A point for the pelvis is the contact surface the body
sits on; the body's own offset (its pelvis joint above the surface) is the game's, since it depends on the skeleton.

## The runtime

- `interact_find(obj, name)`: the row, -1 if none (keep the index; a load-time ask).
- `interact_world(i, ox, oy, oz, oyaw, out)`: a point in the world for an object standing there.
- `interact_solve(px, py, pz, pyaw, bx, by, bz, out)`: the sit-target solve. Given the body part's offset from the root in the current
  pose (`bx` right, `by` up, `bz` forward: a joint's model-space place, or a clip's last key) and a world point, the root place and yaw
  that put the part on the point. Root only.
- `interact_warp(t, t0, t1)`: the weight of a warp window (0 before, 1 after, smooth inside).
- `interact_error(...)`: the distance between a body part as drawn and its point: measure it in world space from the renderer's
  posed skin, never from the numbers that placed it.
- `interact_marker(m, render3d_st, x, y, z, yaw, part)` after `interact_markers_begin(m)`: a debug box and a facing stick, coloured by
  part (pelvis orange, feet green, right hand blue, left hand cyan, eye magenta).

## Measuring

`tools/measure.py <file.glb> <node>` prints rows:

- from empties (preferred): every `SOCKET_<name>` node under `<node>` (Blender: an empty; its local +z is the facing; glTF `extras`
  `{"part": ..., "radius": ...}` give the rest, else the part comes from the name);
- from the mesh (`--seats N --reach R`): for models without empties (the benches). The seat's top is the highest upward-facing
  surface under 0.7 m, the SEAT 0.12 m in front of the seat's back edge (`--back`), the places 0.7 m apart like ludic.crowd's, and each
  STAND the SEAT moved `R` forward (the sit clip's pelvis travel, which is the solve of its last key).

## Converting other data

- **Cars** (`cars_seat_points.lres`, CarSeats rows with `x y z` seat and door data): each car model becomes an `obj`; its seat is
  `seat_<role>` with `part: "pelvis"`, its handle `handle_<door>` (`hand_r` or `hand_l` by side), `enter_<door>`/`exit_<door>` feet
  points (`part: "feet"`, yaw the way the ped faces), `wheel_l`/`wheel_r` hand points with the steering axis in `ax ay az`, `shifter`
  and `handbrake` `hand_r`. Mind the frame: CarSeats' `z` is the car's frame (the boat's `seat_driver` empty is glb z +0.8, its row
  z -0.8); write rows in one frame per object and say which.
- **Weapons**: each weapon is an `obj` in its glb frame; `grip` (`hand_r`, full rotation: yaw/pitch/roll), `support` (`hand_l`),
  `mag` (`hand_l`, for the reload), `sight` (`eye`, `ax ay az` the line of sight). An IK target is the world point of the row
  (`interact_world`) under the weapon's bone.
