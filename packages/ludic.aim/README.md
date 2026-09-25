# ludic.aim

What the crosshair is on, and which thing the use key means. The crosshair is the exact middle of
the screen and the projection is symmetric, so the ray through it is the camera's position along its
forward - no unprojection. Each candidate is an upright cylinder widened by a fixed angular
forgiveness, and the pick is the nearest one the ray enters that the ground does not hide. Uses
[`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.aim"
```

The package keeps no list of things: the game offers every candidate each frame (`aim_offer`), keeps
the object behind the id it gave, and draws the rim and the prompt.

## The rule it keeps

**The crosshair decides WHICH, the distance decides WHETHER** (`aim_use(kind)`):

| | |
| --- | --- |
| under the crosshair and in reach | `AIM_USE_THIS` - that, whatever else is nearer |
| under the crosshair and too far, within `AIM_USE_MAX` (10 m) | `AIM_USE_NOTHING` - and the prompt says why |
| nothing of that kind aimed at, or aimed past 10 m | `AIM_USE_NEAREST` - proximity is right again |

Every reach is floored at `AIM_REACH_MIN` (3 m) by `aim_reach_of(reach)`: a per-kind reach chosen
against its model was never chosen against standing between two props and looking at one. Anything
that asks "am I close enough to this" asks `aim_reach_of`.

## The port

```ludic
export port AimView {
  x, y, z, fx, fy, fz, fov,       # the camera (the ray)
  ground: fn(float, float) -> float,
  dry: fn(float, float) -> bool,  # land, for the probe's viewpoints
  body_x, body_z                  # distances and reach are the body's, not the camera's
}
```

Every member has a default: a camera 1.5 m up at the origin looking down -z over flat ground.

## API

| | |
| --- | --- |
| `aim_begin()`, `aim_offer(kind, id, x, y0, y1, z, r, reach, far) -> bool` | a frame's candidates: true when this one is now the pick (`reach` `AIM_NEVER` is never in reach) |
| `aim_kind()` (`AIM_NONE` for nothing), `aim_id()`, `aim_dist()`, `aim_in_reach()`, `aim_t()`, `aim_off_centre()` | the pick |
| `aim_use(kind)` -> `AIM_USE_THIS` / `_NOTHING` / `_NEAREST`, `aim_reach_of(reach)` | the use key |
| `aim_ray_cyl(cx, y0, y1, cz, r)`, `aim_slack_m(dist)`, `aim_clear_to(x, y, z)`, `aim_range(x, z)`, `aim_miss(cx, cz, r)` | the geometry, for a game's own probes |
| `aim_probe_ground(px, pz, look) -> bool`, `aim_probe_seen()`, `aim_probe_blocked()`, `aim_probe_disagree()` | from a point and a ring round it, lines at 60, 120 and 200 m on 36 bearings: the ground's own answer against `aim_clear_to`; `look(x, y, z)` puts the game's camera there |

## Tests

```bash
ludic test packages/ludic.aim
```

A camera over flat ground with a ridge: the ray against a cylinder, the forgiveness, near before
far, the ground hiding a thing, the reach floor and the three answers for the use key, and the probe.
