# ludic.character

One walking body under a player's stick, seen from over its shoulder: the gait's walk and run with
their acceleration, a jump with gravity, the step-versus-slope rule, wading that shelves into a swim,
diving on a breath, sitting, one answer to "where can this body be put down", holds, being carried,
and the orbit camera with its first-person eyes. Uses [`ludic.base`](../ludic.base/README.md) and
nothing else.

```ludic
import "ludic.character"
```

The package never draws. It moves a body and works out where a camera goes; the game poses a figure
from the queries (`body_phase()`, `body_sit_t()`, `body_swim_phase()`, ...) and hands `body_eye_*`
to its renderer. What happened is a fact (`char_facts()`); the game says the words, plays the
sounds and charges the energy.

## The rules it keeps

- **A pure query of the world stays pure.** `CharacterGround.height` is the world's ground and never
  the body's; what the feet can stand on is `char_stand_at(x, z, from_y)`, and only the movement asks.
- **A step up and a slope up are different refusals** (`char_slope_blocks`). Within `CHAR_STEP`
  (0.55 m) of the feet is a step, taken whatever its gradient; above it the boots
  (`slope_limit`, a rise per metre) decide over `CHAR_SLOPE_PROBE` (0.6 m), never over the frame's
  own step - so 30 Hz and 240 Hz refuse at the same place.
- **Where a body is put down is one question with one answer** (`char_safe_spot`): clear of every
  collider, no deeper than asked, within `CHAR_DROP` of the height left, on ground it can walk off.
- **A collider has a height**: `push` takes the body's span (y0, y1), and `top_at` reports a top it
  could step onto.
- Real time, not frames: every rate is multiplied by `dt`.

## The ports

```ludic
export port CharacterGround {
  height: fn(float, float) -> float                          # the world's ground, pure (required)
  top_at: fn(float, float, float, float, float, float) -> float   # (x, z, r, from_y, step, base)
  bed: fn(float, float) -> float                             # under water (unbound: height)
  water: fn(float, float) -> float                           # the surface (unbound: never wet)
  push: fn(float, float, float, float, float) -> bool        # (x, z, r, y0, y1) out of the colliders
  pushed_x: fn() -> float                                    # ... to here
  pushed_z: fn() -> float
  slope: fn(float, float) -> float                           # 0 flat .. 1 wall (for sitting)
  slope_limit: fn() -> float                                 # the boots: rise a metre (1.05)
  current: fn(float, float, float, float) -> float           # (x, z, fx, fz): a stroke's share lost
}
export port CharacterBody {
  pace, sneaking, breath, riding, ride(ix, iz, run, dt), holding, hold_x, hold_z, eyes_ok
}
export port CharacterInput {
  move_x, move_z, run, jump, look_yaw, look_pitch, zoom, look_always
}
```

Only `height` is required; unbound, the rest is a dry plain with no colliders, a fresh body and a
still stick.

## API

| | |
| --- | --- |
| `char_update(ix, iz, run, jump, dyaw, dpitch, dt)` | a frame from explicit input; `char_tick(dt)` reads `CharacterInput` (nothing while held) |
| `char_teleport(x, z, yaw)`, `char_stand_on`, `char_push_to`, `char_face`, `char_halt`, `char_go_limp`, `char_resume_swim(dive, depth, breath)`, `char_map_changed()` | placing and stopping the body |
| `char_config(walk, run)`, `char_allow_run(on)` | 3.2 and 6.8 m/s by default; a spent body cannot run or jump |
| `char_sit(x, z, yaw, mode)`, `char_sit_here() -> CHAR_SAT / _STOOD / _NOT_RIDING / _NOT_AIRBORNE / _NOT_STEEP / _NOT_WET`, `char_stand()` | sitting (`CHAR_SIT_SEAT`, `CHAR_SIT_GROUND`) |
| `char_hold(reason)`, `char_release(reason)` (`CHAR_HOLD_SCREEN`, `CHAR_HOLD_STAGE`) | holds by reason: two holders cannot release each other |
| `char_board(x, z, yaw)`, `char_ride_at(x, y, z, yaw, speed)`, `char_step_off(x, z)` | carried by something (`CharacterBody.riding`/`ride`) |
| `char_safe_spot(x, z, from_y, max_depth) -> bool`, `body_safe_x()`, `body_safe_z()` | somewhere to put a body down |
| `char_stand_at(x, z, from_y)`, `char_slope_blocks(nh, fx, fz)` | the step rule, for a game's own movers |
| `char_camera(dt)`, `char_camera_third(dt)`, `char_look(yaw, pitch)`, `char_look_pitch`, `char_orbit(dist)`, `char_lock_orbit`, `char_set_fps`, `char_fps_toggle() -> CHAR_EYES_*` | the camera; read it back with `body_eye_x/y/z/yaw/pitch()` and `body_eyes_now()` |
| `body_x()`, `body_y()`, `body_z()`, `body_yaw()`, `body_speed()`, `body_moving()`, `body_run()`, `body_phase()`, `body_time()`, `body_water()`, `body_airborne()`, `body_vy()`, `body_landing()`, `body_steep()`, `body_step()`, `body_sitting()`, `body_sit_mode()`, `body_sit_t()`, `body_swimming()`, `body_diving()`, `body_depth()`, `body_breath()`, `body_breath_max()`, `body_floating()`, `body_swim_phase()`, `body_can_run()`, `body_held()`, `body_fps()`, `body_cam_yaw()`, `body_cam_pitch()`, `body_cam_dist()` | the queries |
| `char_wrap(a)`, `char_toward(cur, target, rate)`, `char_ease(t)` | the helpers a pose needs |
| `char_facts() -> Queue<CharacterFact>` | `{ what, x, y, z, v }`: `CHAR_LANDED`, `_JUMPED`, `_FOOTFALL`, `_TOO_STEEP` (once per refusal), `_STARTED_SWIMMING`, `_LEFT_WATER`, `_OUT_OF_AIR` (v: seconds), `_CURRENT` (every 12 s) |
| `char_reset()`, `char_system() -> System` | `"character"`, `PH_INPUT`, nothing saved: where a body stands is the game's to write |

## Tests

```bash
ludic test packages/ludic.character
```

A fake world of a meadow, a 45 cm deck, a cliff, a gentle rise, a boulder and a shelving lake: the
step and the cliff at 30, 60 and 240 Hz, speeds and the sneak, wading into a swim and out, the dive
and the breath, the jump, the safe spot, sitting and its refusals, holds, riding and the camera.
