# ludic.carbody

[`ludic.cars`](../ludic.cars/README.md)' body and wheel rays over [`ludic.physics`](../ludic.physics/README.md) (Jolt). The car
simulation puts the suspension, tyres and drivetrain on a body as forces; this is the body that takes them, so a game
binds it in two lines and writes no adapter:

```ludic
import "ludic.cars"
import "ludic.physics"
import "ludic.carbody"

bind CarBody { make: fn carbody_make, drop: fn carbody_drop, read: fn carbody_read, push: fn carbody_push, torque: fn carbody_torque, step: fn carbody_step }
bind CarWorld { cast: fn carbody_cast }     # add `grip: fn my_grip` for a surface that grips less
```

- **The body** is a box of the model's `width` x `height` x `length` about its centre (`car_body_centre` above the origin),
  the model's `mass`, made in the game's open `PhysicsState` (`phys_open` first; `make` refuses while it is closed, for an unknown
  model or for a place that is not a number, and cars then fall back to the planar model).
- **Forces** come in at the points they act (`push`: the force through the centre and the torque its lever makes) and as
  a twist (`torque`); `step` steps the physics world once (ludic.physics keeps its own fixed 1/60 s).
- **The wheel ray** (`carbody_cast`) is a `phys_ray` against `PHYS_M_SOLID`; the hit's grip is the game's `CarWorld.grip`
  at the point it found, 1 when unbound.
- **Forward is the body's +z, up its +y**, and the body's yaw is the car's yaw (the conventions of ludic.cars).
- A pose, force or ray made of NaN or an infinity is never passed on: `read` answers false (the car drops to the planar
  model) and `push`, `torque` and `cast` do nothing.
- Nothing is allocated after a car's body is made.

The state is `CarBodyState` (the ids of the bodies by the car's id); a game declares none of it.
