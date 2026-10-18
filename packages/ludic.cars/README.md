# ludic.cars

Wheeled vehicles - cars, trucks, buses, motorcycles, bicycles - as data and a simulation behind ports: their
handling (engine curve, gears, brakes, steering, axles, tyres, aero), tuning parts, paint and classes as rows; a
raycast-wheel model over the game's physics body, a planar model and a lane follower at a distance; getting in,
getting out and carjacking as a machine; ownership with garage slots, insurance, delivery and the impound; and
snapshots for a party. Uses [`ludic.base`](../ludic.base/README.md) and nothing else. The Jolt body and wheel rays over
[`ludic.physics`](../ludic.physics/README.md) are [`ludic.carbody`](../ludic.carbody/README.md): two `bind` lines.

```ludic
import "ludic.cars"
```

The package carries no content: every number is a row a game writes (`def CarModels from "cars.lres"`). It
draws nothing, prices nothing and plays no animation. The world, the physics body, the road, the people in the
seats and the money are ports, all defaulted, so a car drives with every one unbound.

Conventions: metres, kilograms, seconds, newtons; **x east, y up, z south**; `yaw = atan2(forward.x, forward.z)`,
yaw 0 faces +z (the conventions of `ludic.roads` and `ludic.melee`); the right of a heading `h` is `(-h.z, h.x)`. A
model's own space has x to the right of the car, y up from the ground it stands on, z forward; its origin is where
the wheels' ground plane is.

## The data

Every registry is `open` and `@ByKey`; a game fills it with `def Registry from "file.lres"`.

| Registry | Row | What it is |
| --- | --- | --- |
| `CarModels` (`CARM_*`) | `CarModel` | the handling of a model, all of it |
| `CarTyres` (`CART_*`) | `CarTyre` | a compound: normalised slip-to-grip curves, load and surface sensitivity |
| `CarClasses` (`CARC_*`) | `CarClass` | compact, sports, super, muscle, SUV, truck, motorcycle, bicycle, bus... as the game names them: a kind (`CAR_KIND_CAR` or `CAR_KIND_BIKE`), a rank, what a claim and the impound cost, the delivery and claim times |
| `CarParts` (`CARPT_*`) | `CarPart` | tuning: engine, brakes, transmission, suspension, turbo, armour, tyres, each level a row of stat modifiers |
| `CarLiveries` (`CLIV_*`) | `CarLivery` | `@Color` primary, secondary and pearlescent, `@Asset("png")` livery and decal textures, for one model or (`car: -1`) any |
| `CarSeats` (`CSEAT_*`) | `CarSeat` | where a sitter sits in the model (`@Ref(CarModels)`), which seat drives, its door, the animation graph states it asks for |
| `CarSockets` (`CSOCK_*`) | `CarSocket` | a named node of the model's glTF (`@Node`): wheels, doors, exhausts, lights, with the door's clips (`@Clip`) |
| `CarSettingsRows` (`CARSET_*`) | `CarSettings` | the simulation's own numbers; the first row is the one in use |

A model (abridged; the test data in `tests/cars_models.lres` is complete):

```lres
sedan {
  cls: CARC_SPORT, price: 20000, mass: 1400.0, length: 4.4, width: 1.8, height: 1.3, ground_clear: 0.2, com_y: 0.5
  drivetrain: CAR_RWD, idle: 900.0, redline: 6500.0, limiter: 6900.0, engine_brake: 60.0
  torque: [{ x: 1000.0, y: 180.0 }, { x: 4000.0, y: 300.0 }, { x: 6500.0, y: 240.0 }]     # rpm -> N.m
  gears: [3.6, 2.3, 1.6, 1.2, 0.95, 0.78], reverse: 3.3, final_drive: 4.1, shift_time: 0.2
  brakes: 14000.0, brake_front: 0.62, handbrake: 16000.0
  steer_lock: 34.0, steer_curve: [{ x: 0.0, y: 1.0 }, { x: 20.0, y: 0.22 }, { x: 60.0, y: 0.06 }]   # m/s -> share of the lock
  axles: [
    { z: 1.3, track: 0.78, y: 0.48, radius: 0.33, steer: 1.0, spring: 35000.0, damper: 3000.0, rebound: 3800.0, bar: 6000.0, tyre: CART_ROAD }
    { z: -1.3, track: 0.78, y: 0.48, radius: 0.33, handbrake: true, spring: 35000.0, damper: 3000.0, rebound: 3800.0, tyre: CART_ROAD }
  ]
  drag: 0.42, downforce: 0.0, top_speed: 0.0, nitro: 0.5, nitro_time: 4.0, nitro_recharge: 20.0
  health: 1000.0, engine_health: 400.0, tank: 50.0, arcade: 0.3, assist_traction: 0.35
}
```

- **Drivetrain**: `CAR_FWD`, `CAR_RWD` (the axles behind the middle of the axles) or `CAR_AWD` (`front_share` to the
  front). Engine torque is a curve of points over rpm; `gears` are ratios from first, with a `reverse` and a
  `final_drive`; a box is `auto` (changing at `up_at` / `down_at` of the redline on the GROUND's speed, not on a
  spinning wheel's) or shifted by `car_shift`. Torque is cut for `shift_time` while a gear changes. The engine's
  inertia reaches the wheels through the gear, so a launch builds wheelspin over a fraction of a second and a
  stiff tyre cannot ring.
- **Axles**: any number (a bus has three), one wheel on the centre line for `track: 0` (a bike). Each has its
  suspension (`travel`, `spring`, `damper`, `rebound`, an anti-roll `bar`), its `steer` share (negative steers
  against), `handbrake`, and its tyre. A wheel's socket in the model is `CarSockets` kind `CAR_SOCK_WHEEL`, index
  `axle * 2 + side`.
- **Tyres**: the curves are normalised (1 is the most a tyre gives, `mu` times the load), so one compound serves
  any car. `load_sens` takes grip off as the load rises (a loaded tyre grips more, but less per newton),
  `surface_sens` says how much a loose surface costs it (a road tyre loses more than a rally tyre).
- **Centre of mass**: `com_x`, `com_y`, `com_z` from the model's origin (`com_y: 0` is the body's own middle).
- **Handling as a blend**: `arcade` (0 a simulation, 1 an arcade: extra grip, a steadier yaw, a stick that eases
  off at speed) plus `CarSettings.sim_blend`, and the assists `assist_traction`, `assist_stability`,
  `assist_drift`, `assist_abs`; a game sets a live car's own with `car_assist`.
- **Tuning**: `CarParts` rows multiply (`torque`, `brakes`, `shift`, `gearing`, `spring`, `damper`, `bar`, `grip`,
  `drag`, `top_speed`, `health`) or add (`mass`, `armour`, `boost`); a car has one part per slot
  (`car_fit` / `car_unfit`); `car_stats_into(model, parts, stats)` is the pure function of it all.
- **Nitrous**: `nitro` extra torque while it burns, `nitro_time` seconds a tank, `nitro_recharge`.
- **Limits**: `top_speed` (faded in over the last two m/s), the rev `limiter`, `tank` and `burn` (0 tank: no fuel).

## Animation: the package moves no bone

What is seen - getting in, sitting, stepping out, being dragged out, a door opening, a steering wheel, the gear
lever - is clips played by the game's animation graph (`ludic.anim` `AnimSets`, from Blender or Mixamo clips). The
package names graph STATES and PARAMETERS in data and asks for them through `CarAnim`:

- `CarSeat.state_enter`, `state_sit`, `state_leave`, `state_jacked` are states of the sitter's own graph, asked with
  `CarAnim.rider_request(actor, state)` at the moment they begin; `CarSeat.clip_door` and the door's
  `CarSocket.clip_open` / `clip_close` (`@Clip` of the car's model) through `CarAnim.car_request(nid, clip)`.
- `CarSettings.param_*` are parameter names (`car_speed`, `car_steer`, `car_throttle`, `car_gear`, `car_rpm`,
  `car_door`, `seat_state`): each frame `CarAnim.car_param(nid, name, value)` tells the car's graph its speed, steer
  angle (radians, right positive), rpm and gear, and `rider_param(actor, ...)` tells the driver's graph the steer
  share of the lock, the speed and the throttle - what a blend between steering clips is driven by.
- What a game draws a wheel with is `CarWheel`: `roll` (radians turned), `steer`, `ext` (how far the suspension is
  out); a model's wheel nodes take those. Wheel spin is physics; turning the node is the renderer's.

## The simulation

A car is one of three levels at a time, chosen each frame by `CarWorld.focus` (the distance to the nearest
viewer) with a margin so a car on the line does not flip, and every level is the SAME drivetrain, tyres and
inputs:

| Level | `sim` | What it is |
| --- | --- | --- |
| body | `CAR_SIM_BODY` | the game's physics body with a ray cast down each wheel's suspension: a spring and damper, a tyre under the steering, the engine's torque and the brakes, each pushed at the point it acts |
| planar | `CAR_SIM_PLANAR` | a single-track model on the ground: each end of the car is one tyre carrying its share of the weight, with load transfer under acceleration; no body |
| lane | `CAR_SIM_LANE` | no forces: the speed moves to the plan's within what the car's grip and power can do, the heading follows the lane's curvature within what the steering can turn |
| remote | `CAR_SIM_REMOTE` | simulated on another machine: snapshots, interpolated |

A person's car (its driver is `CarWorld.is_player`) is always a body, and so is a car mid-door or being
jacked. Within `body_dist` of a viewer an AI car is a body; within `planar_dist` planar; past it a lane
follower. A body is made (`CarBody.make`) at the pose and velocity the planar model left, and let go
(`CarBody.drop`) when the car leaves; with `CarBody` unbound `make` refuses and the car stays planar (and asks
again in two seconds).

**Why raycast wheels, not Jolt's vehicle constraint.** `ludic.physics`'s native shim binds bodies, shapes,
queries, characters and buoyancy; Jolt's `WheeledVehicleConstraint` is not bound, and adding it means new shim
functions and a rebuild of both `lib/` binaries (the Windows one cannot be built from a Mac). A raycast-wheel
model through ports needs nothing from the native layer, is deterministic (fixed step, no floating point
shortcuts, the same run twice is the same to the bit - a test holds it), and keeps the body, the planar model
and the lane follower on one tyre model. The price is that the body's box, mass and inertia are Jolt's, from the
shape the game makes. The centre of mass is emulated: the body's own centre is the box's middle, and the
torque the offset makes of the tyres' forces is applied as a correction (`com_y` low cars roll less).

**Forces** (body level): a wheel's ray gives a hit (distance, surface normal, grip); compression is `travel`
minus the reach, the force `spring * compression + damper * speed` (`rebound` when the wheel drops), with a bump
stop past full compression; anti-roll bars push the more compressed wheel of an axle up and the other down. The
tyre's force at the contact is solved as a tyre does it: if the torque asked of the ground is within what the
tyre can grip, the wheel follows the ground at the slip that gives exactly that force; beyond it the wheel spins
up or locks, stepped against its inertia, and the force is the curve's at the slip it has. The friction circle
keeps the lateral and longitudinal forces inside `mu * load`. Drag and downforce act at the body's middle. Traction
control and anti-lock are limits on the torque asked of a tyre (near its peak), stability control a yaw torque
toward the yaw rate the steering asks, the drift assist lets the rear go while the handbrake is held or the car is
across its line and aligns a slide, and a two-wheeler's `balance` is a roll torque toward the lean its speed and
steering ask for.

**The lane** comes through `CarRoad` (`ludic.roads` through the game): `aim(nid, x, z, yaw, look)` answers with
the lane point `look` ahead (`tx()`, `tz()`, `tyaw()`, `limit()`), `ahead(...)` with the distance to what is in the
way. The plan is pure pursuit for the steering, the lane's limit times the car's `ai_pace`, the corner's speed
`sqrt(5.5 / curvature)` and a gap to what is ahead: `car_follow_lane(nid, true, pace)` and an AI driver
(`car_seat_driver`) make a traffic car; the same plan steers a body or planar car through the stick and pedals and
moves a far one with no forces.

**Fixed steps.** `cars_step(dt)` is one step of every car; `cars_tick` runs as many as the frame holds
(`CarSettings.step`, at most `max_steps`) and calls `CarBody.step(dt)` after each so a game that steps its
physics there keeps the forces and the step one-to-one (the forces a step pushes last one physics step).
Unbound, the game steps its physics itself once per car step.

## The ports

All defaulted; a game binds what it has.

```text
export port CarWorld {       # cast(ox, oy, oz, dx, dy, dz, length, hit), ground(x, z), grip(x, z), focus(x, z), me(), host(),
  ...                        # is_player(actor), next_id(), made(nid, model), gone(nid), spawn_point(x, z, r), spawn_x/z/yaw()
}
export port CarBody { make, drop, read, push, torque, step }
export port CarRoad { aim, tx, tz, tyaw, limit, ahead }
export port CarRider { board, alight, safe_spot, safe_x, safe_z, reach }
export port CarAnim { car_param, car_request, rider_param, rider_request }
export port CarBank { can_pay, pay, refund }
export port CarPlaces { free, x, y, z, yaw }
```

- `CarBody` is the body in the game's physics. The body's origin is the model's origin, its forward local +z and its
  up local +y; the game makes a box of the model's `length`, `width`, `height` about it, `ground_clear` above the
  ground. `read(nid, pose)` fills `CarPose` (origin, forward, up, velocity); `push(nid, force, point)` is a force
  at a world point over the next step, `torque` a twist. `tests/fakes/jolt_body.ludic` is the reference binding
  to `ludic.physics`, about sixty lines, and is what the body tests run on.
- `CarWorld.cast` is the wheel ray (unbound: the ground height from `ground`); its `CarHit` carries the surface's
  `grip` (1 tarmac, less for loose ground), which a tyre's `surface_sens` scales.
- `CarPlaces` are a property's garage slots or a lot, by the game's number for a place; the package knows them only
  as numbers and asks where each is and whether it is free.

## Getting in and out: the door machine

A car's `phase` is a `@Machine(Car.phase)` whose graph is a table, `steps.lres`: `Free`, `Locked`, `Entering`,
`Driven`, `Exiting`, `Jacked`, `Wrecked`. The verbs check what a person could see for themselves - reach
(`CarRider.reach`), a free seat, a locked door, a wreck, speed - say why not as a `CAR_REFUSED` fact
(`CAR_NO_*`), and dispatch an action the machine reduces.

| Verb | |
| --- | --- |
| `car_enter(nid, actor, seat)` | the driver's seat through the machine (the seat is reserved at once, the engine runs once the door has closed, `door_time`); a passenger's at once. Locked: the owner only |
| `car_exit(nid, actor)` | too fast (`exit_speed`) is refused; the actor is put out beside the door (`CarRider.safe_spot`), the engine goes off |
| `car_carjack(nid, actor)` | a driven car: `Jacked` for `jack_time`, then the driver is put out and the thief gets in; the driver escapes by flooring it (`Jacked` back to `Driven`). A locked empty car: broken into |
| `car_lock(nid, on)`, `car_seat_driver(nid, actor)` | lock and unlock; an AI driver at the wheel with no door to open |

Facts: `CAR_ENTERED`, `CAR_EXITED`, `CAR_CARJACK`, `CAR_EJECTED`, `CAR_BROKEN_INTO`, `CAR_LOCKED`, `CAR_UNLOCKED`, `CAR_BOARDING` (began to get in), `CAR_DRAGGED` (the driver being dragged out); those about a seat carry the seat's graph state as `CarFact.word`.

## Signals: seats and doors for a graph with no glue

`signals.ludic` declares `SignalSources` (`ludic.base`) so a person's graph is fed by `AnimBindings` rows (`ludic.anim`) and a game writes no `CarAnim` port for the rider. The actor is the game's number for the rider (the one handed to `car_enter`). A fact's **word** is the graph state the seat row names for that act (`CarSeat.state_enter` / `state_sit` / `state_leave` / `state_jacked`: `enter_left`, `sit_drive`, `exit_right`, `dragged_left`), so one request-by-name row (`by_name: true`) covers every seat and side. The facts are read, never drained.

| Source | Kind, range | Says |
| --- | --- | --- |
| `cars.BOARDING` | fact | an actor began to get in through the door (a driver's seat through the machine, a thief after a carjack): word `state_enter`, value the seat. A passenger takes the seat at once and has only `SEATED` |
| `cars.SEATED` | fact | an actor is in a seat: word `state_sit`, value the seat |
| `cars.EXITED` | fact | an actor stepped out: word `state_leave`, value the seat |
| `cars.EJECTED` | fact | an actor was thrown or dragged out (a wreck, a carjack): word `state_leave` |
| `cars.DRAGGED` | fact | the driver is being dragged out: word `state_jacked` (actor: the driver) |
| `cars.riding` | value, 0/1 | in a seat of a car, from the start of getting in |
| `cars.driver`, `cars.passenger` | value, 0/1 | in the driver's seat; in any other seat |
| `cars.speed` | value, m/s | the speed of the car the actor is in (negative backing up) |
| `cars.steer` | value, -1..1 | its steering as a share of the lock, right positive (a steering layer's blend space) |
| `cars.door` | value, 0/1 | 1 while the door works (getting in, getting out, being jacked) |
| `cars.seat_state` | text | the state the rider's graph belongs in now: `state_enter` while they get in, `state_jacked` while dragged, else `state_sit`; `""` outside a car. Bound as a request by name it names the seat pose with no fact needed |

Wiring (rows, no code): `{ set, kind: "request", by_name: true, source: "cars.BOARDING" }` and the same for `cars.SEATED`, `cars.EXITED`, `cars.EJECTED`, `cars.DRAGGED`; `{ to: "riding", source: "cars.riding" }` and `cars.speed` / `cars.steer` into parameters.

## Damage, small states, facts

The package does not see collisions: the game reports a blow (`car_hit(nid, speed_change, direction, point)`, from its
physics contacts; `car_damage(nid, amount, wheel)` for a bullet or a fire). Under `crash_speed` it does nothing;
over it costs `2 * excess^2 * (1 - armour)` of body health, part of it the engine's (more from the front), and
a hard one may flatten the nearest tyre (the package's own dice, seeded). A dent is a **fact** (`CAR_DEFORM`: the
model-space point, the depth, the direction) for the game to show on the mesh - the package keeps no vertices.
Engine smoke is `CAR_SMOKE` (1 light, 2 heavy, 3 afire); health at 0 dispatches the machine's wreck: everybody
out, the engine off, `CAR_WRECKED`; `car_repair` mends it. With `CarSettings.breakdown` on, health at 0 **breaks the car
down** instead (`CAR_BROKEN`, `car_broken(c)`): health stays at 0, the engine is dead and off and will not start, nobody
is thrown out, and the steering and the brakes work on (with the engine off the brake pedal is always a brake, never
reverse); the engine keeps a tenth of its health while the body lives, so it dies with the body. `car_set_health(nid, hp)`
sets the body's health (a broken car given some gets its engine back in proportion and runs at once with a driver);
`car_repair` mends it and restarts the engine under a driver. Under `CarSettings.sputter_at` of body health a running
engine misfires: spells of firing (less torque the lower the health) and of missing (a tenth), each miss a `CAR_MISFIRE`
fact. `car_engine`, `car_horn`, `car_lights` (`CAR_LIGHT_*`;
the brake and reverse lights are worked out), `car_indicator`, `car_shift`, `car_nitro`, `car_refuel`,
`car_paint`, `car_livery`, `car_plate`, `car_fit` / `car_unfit` are the rest of what a game sets. Skids
(`CAR_SKID`), a fall (`CAR_AIRBORNE`, `CAR_LANDED`), gear changes (`CAR_SHIFT`), nitrous (`CAR_NITRO`) and the
level of detail (`CAR_LOD`) are facts too; drain `cars_facts()`.

## Ownership, garages, insurance, delivery, the impound

`OwnedCar` rows, their `status` a `@Machine(OwnedCar.status)` (`own.lres`): `Garaged`, `Delivering`, `Out`,
`Destroyed`, `Claiming`, `Impounded`. A player's garage slots are places the game hands out
(`car_slot_add(pid, place)`); `car_own_add(pid, model, insured)` puts a car in a free one.

| Verb | |
| --- | --- |
| `car_retrieve(oid)` | out of its slot, standing at the slot's place |
| `car_call(oid, x, z, yaw)` | it arrives after its class's `deliver_time`, at `CarWorld.spawn_point` near the caller |
| `car_store(oid)` | back into a free slot (refused with somebody in it); health, fuel, paint and parts are kept |
| `car_claim(oid)` | a destroyed, insured car: the fee (`price * insurance`) paid through `CarBank`, settled after `claim_time`, whole and stock in a slot |
| `car_insure(oid, on)` | a policy costs a quarter of a claim |
| `car_impound(oid)`, `car_release(oid)` | towed away; out again at `CarSettings.impound_place` for `price * impound` |

The tick makes and takes away the live car as the machine asked. A live car knows its `oid`; when it is wrecked
the row becomes `Destroyed` (the wreck stays in the world, nobody's). Facts: `CAR_OWN_STATUS`, `CAR_DELIVERED`,
`CAR_CLAIM_PAID`, `CAR_IMPOUNDED`, `CAR_RELEASED`. The save section `cars` holds the owned rows by model, part
and livery KEY (so a reorder of the registries does not break a save), the slots and the counters; an out car
is made again where it stood.

## Multiplayer

**The model: one authority per car.** The machine that simulates a car (`Car.auth`) is either the host for
every car (`CAR_AUTH_HOST`, the default) or the driver's own machine for the car it drives
(`CAR_AUTH_OWNER`: its handling feels exact to its driver, and the host checks what it claims); with nobody
driving, the host. A guest's own car under host authority is driven by its controls alone.

- **The authority sends** a snapshot of each car it simulates at `snap_hz` (`car_snap_due(nid, dt)`, then
  `car_snap_write(nid, out, at)`): fourteen ints - id, the sender's time in ms, position in mm, yaw, pitch and lean
  in 1/10000 rad, speed, steer, rpm and gear, flags (engine, horn, nitrous, indicators, lights, phase, smoke,
  airborne), the tyres flat, health and engine health in thousandths. The ints are written into a slice the game
  keeps (`words(n)`) and carried in `ludic.net` messages (`nw_i` / `nr_i`); nothing is made.
- **Everybody else** reads it (`car_snap_read(words, at, from)`) into the car's ring of eight and shows the car
  `interp_delay` in the past, interpolated between the two snapshots that bracket that time (position and angles
  linearly, angles the short way), and carried on along its heading a quarter of a second at most past the
  newest. The clock is the sender's, mapped with the best (least-delayed) offset seen, so jitter does not
  move the car. A remote car's wheels turn with its speed and its flat tyres are shown.
- **A guest that drives under host authority** sends its controls - six ints, `car_input_write` - and the host applies
  them with `car_input_read(words, at, from)` only when `from` is the car's driver.
- **Refused**: a snapshot from a machine that is not the car's authority, for a car this machine simulates, or
  claiming more than `max_speed_check` between two snapshots (`CAR_SNAP_REFUSED`, with the actor).
- `car_set_authority(nid)` moves a car to the machine its settings now say (a driver got in or out): it becomes remote
  or local with its last pose kept.
- **Zero allocation**: the per-frame paths touch only kept records, rings and caller-owned slices; a test holds the
  heap flat over hundreds of frames for body, planar, lane and remote cars.

## Editor verbs

`cars_near x z r max?` (`id x y z yaw speed engine_on` records, nearest first, at most 16, wrecks included) and
`car_get id` (`x y z yaw speed engine_on`), declared in `devverbs.ludic`; the id is the nid, the yaw render3d's
degrees. The convention is in `ludic.devlink`.

## API, in short

`car_spawn(model, x, z, yaw, owner) -> nid`, `car_remove`, `car_by_nid`, `car_count` / `car_at`, `car_nearest`,
`car_place`; the controls `car_drive(nid, throttle, brake, steer, hand)` (steer positive right), `car_nitro`,
`car_engine`, `car_shift`, `car_horn`, `car_lights`, `car_indicator`, `car_assist`, `car_follow_lane`; the
machine's verbs above; `car_hit`, `car_damage`, `car_pop_tyre`, `car_repair`, `car_refuel`; `car_paint`,
`car_livery`, `car_plate`, `car_fit`, `car_unfit`; ownership as above; the snapshot functions above;
the pure math `car_curve`, `car_ratio`, `car_speed_at`, `car_engine_torque`, `car_power`, `car_stats_into`,
`car_tyre_long` / `_lat` / `_peak` / `_mu`, `car_rest_height`, `car_wheelbase`, `car_axle_*`; `cars_step(dt)`,
`cars_tick`, `cars_system()` (`"cars"`, `PH_SIMULATE`, its own save section), `cars_reset`, `cars_seed`,
`cars_facts()`, `cars_config()`.

A frame, as a game runs it: dispatch the inputs (`car_drive`, `car_enter` ...), then `cars_tick` through the system
runner (the machines' actions are drained at the end of each phase; call `drain_actions()` yourself outside it),
then read the facts and draw the cars from `Car` (`x`, `y`, `z`, `fx`..`uz` for the basis, `wheels[i]`).

## Tests

```bash
ludic test packages/ludic.cars
```

The torque curve and power, gearing, tyre curves and load sensitivity, tuning modifiers and the data's shape
(`cars_math_test`); the planar model - launch, gears, limiter, braking, reverse, steering, traction control, the
handbrake, fuel, nitrous, slide facts, determinism, zero allocation (`cars_planar_test`); the door machine -
enter, exit, lock, break in, carjack and escape, wreck, with a fake rider port (`cars_doors_test`); the body
model on a real Jolt world - rest on springs, acceleration, braking distance, cornering and roll, gravel, a heavy
bus, a bike held upright, a fall and a landing, the levels of detail handing a car between body, planar and lane,
determinism to the bit (`cars_body_test`); a car following a lane at all levels, slowing for a gap and a bend
(`cars_lane_test`); ownership, insurance, delivery, the impound and the save with a fake wallet
(`cars_garage_test`); damage, armour, smoke, tyres, the small states and a manual box (`cars_misc_test`);
snapshots, interpolation with jitter, extrapolation, refusal and controls (`cars_net_test`); owner authority
(`cars_owner_test`); the signal sources for a graph (`cars_signals_test`).

## v2

Jolt's `WheeledVehicleConstraint` through a shim (a differential, engine and clutch from Jolt itself, both `lib/`
binaries rebuilt); a real centre of mass and inertia in `ludic.physics` bodies (`OffsetCenterOfMassShape`) in place of
the torque correction; trailers and towing; a diff lock and per-wheel torque vectoring; tyre temperature and wear
(`wear_rate` is declared, unused); damage that stiffens a wheel's alignment and drops the engine's power by part;
collision damage from the contact's impulse rather than a speed change the game measures; a sequential and a
manual clutch; boats and aircraft are `ludic.vehicles`' and a flight package's; server reconciliation for a guest's
predicted own car; lane changes and overtaking in the lane follower (`ludic.roads` v2).
