# ludic.vehicles

Each player's boat and horse: called to one of four berths off a pier head or four bays at a trough,
made there the first time and fetched there after, owned by one player and ridden by one at a time,
ridden over water or land, and got off onto a spot the rider's own safe-spot rule found. Uses
[`ludic.base`](../ludic.base/README.md) and nothing else.

```ludic
import "ludic.vehicles"
```

The package never draws, prices or words anything. A game draws a vehicle when `VehicleWorld.made`
says one exists and moves its model on `placed`; it charges for a hire and says the words; and it
binds the rider to its walking body (in Maroon Lake, [ludic.character](../ludic.character/README.md)
through the game).

## The rules it keeps

- **A kind's numbers are the game's data.** The package keeps the rules (a walk and a gallop on
  stamina, a stroke and a turn, where a rider gets off) and no numbers: they are rows of the open
  registry `VehicleSpecs` (`def VehicleSpecs from "vehicles.lres"`; a row's `kind` says which kind it is
  the numbers of, `VEHICLE_HORSE` or `VEHICLE_BOAT`, and `VSPEC_<KEY>` its place). A kind with no row
  and no spec cannot be called; a reset keeps them. Where a rider sits are rows of `VehicleSeats`, each
  naming its kind's row (`vehicle: VSPEC_BOAT`) with a point in the model's own space; the first seat's
  height is the rider's, else the spec's `seat_h`.
  The older way, `vehicles_spec(kind, spec)` from the game's own table, still works before any vehicle is
  made, and what it hands in wins over the row (`null` hands the kind back to it).

  ```lres
  horse { kind: VEHICLE_HORSE, model: "models/horse.glb", node: "horse", seat_h: 1.35, walk: 4.5, run: 11.0, hay_min: 10.0 }
  boat  { kind: VEHICLE_BOAT, model: "models/boat.glb", node: "hull", row: 630.0, row_turn: 270.0, wind: 70.0, off_depth: 1.25 }
  ```

- **Nothing is parked for anyone.** A vehicle has an `owner` and a `rider`; `vehicle_find(kind)` is
  this player's own and nothing else may pick "the" boat. A place is taken while a boat lies in it
  or a horse is tied at it (`home_x`, `home_z`), within half a place's spacing.
- **Where a body is put down is one question with one answer.** Getting off asks the rider's
  `safe_spot` - a wade of up to the spec's `off_depth` within its search from a boat, `off_side` out
  by the right flank from a horse - and a boat too far out refuses and says so (`VEHICLE_NO_LANDING`) rather than dropping the
  rider in the lake.
- **A boat is a body in the game's physics** (`VehicleHull`, phase 16; a buoyant Jolt hull in Maroon
  Lake). The package rows it - the stick forward and back is a stroke along the bow, left and right
  the oars pulled against each other - and reads back where the hull is and how fast it goes. The
  water floats it, the wind (`VehicleWorld.wind`) drifts a rowed boat, and the lake bed stops it at
  the shore. A boat nobody rows is moored where it was called or left (`home_x`, `home_z`,
  `home_yaw`): its hull is put back there whenever it strays, so it never crosses the lake alone; the swell at the sail limit takes the outward share of a stroke.
- **A horse walks on legs in the game's physics** (`VehicleLegs`; a Jolt walker in Maroon Lake). The
  package decides its pace - a walk, a canter on stamina, hay for every metre - and never steps it
  into water; the legs meet the ground, its steps and slopes, and whatever stands in its way. What
  they cover along its heading is its speed, so a fence brings it to a stand and a trunk it glances
  pushes it aside. A horse called to its bay or led round where it is tied is stood there (`stand`).
- **A horse's steering follows signed speed**: backing up with the stick left swings the nose right.
- A stale rider locks a vehicle for ever, so getting off is `vehicle_dismount` or `vehicle_drop`.

## The ports

`VehicleHull { put(nid, x, y, z, yaw), row(nid, forward, turn), drift(nid, fx, fz), read(nid) -> bool,
x, y, z, yaw, speed, gone(nid) }` is required: the boat's body, named by the vehicle's nid.
`VehicleLegs { walk(nid, x, y, z, vx, vz, dt) -> bool, x, y, z, stand(nid, x, y, z), gone(nid) }` is the
horse's: unbound, the ground is walked as it is and only a rise steeper than it can take stops it.

```ludic
export port VehicleWorld {
  ground: fn(float, float) -> float                       # required
  water: fn(float, float) -> float                        # the surface (unbound: never wet)
  swell: fn(float, float, float, float) -> float          # (x, z, fx, fz): a stroke's share lost
  wind: fn() -> float                                     # 0..1
  wind_yaw: fn() -> float                                 # the yaw the wind pushes toward
  next_id: fn() -> int                                    # an id across machines
  made: fn(Vehicle) -> void                               # draw it
  placed: fn(Vehicle) -> void                             # move its model
  gone: fn(Vehicle) -> void                               # its owner left
}
export port VehicleRider {
  board(x, z, yaw), ride_at(x, y, z, yaw, speed), step_off(x, z),
  safe_spot(x, z, from_y, max_depth) -> bool, safe_x(), safe_z()
}
```

## API

| | |
| --- | --- |
| `VEHICLE_HORSE`, `VEHICLE_BOAT`, `VEHICLE_PLACES`, `VEHICLE_KINDS` | the kinds, four places each, and how many kinds may have a spec |
| `VehicleSpec { key, kind, model, node, seat_h, walk, run, acc, turn, row, row_turn, wind, hay_per_m, hay_min, run_min, tire_at, tire, rest, off_side, off_depth }` | a kind's numbers: the seat, a horse's pace, stamina and hay, a boat's oars and wind, where one gets off |
| `vehicles_spec(kind, spec)`, `vehicle_spec(kind)`, `vehicles_specs_from_data()` | set a kind's numbers (at boot, the older way), ask them (handed in, else the `VehicleSpecs` row), and copy every row in as if handed in |
| `VehicleSpecs`, `VehicleSeats`, `vehicle_spec_row(kind)`, `vehicle_seat_count(row)`, `vehicle_seat(row, n)`, `vehicle_seat_height(kind)` | the registries and their questions |
| `Vehicle { kind, nid, x, y, z, yaw, speed, fuel, food, seat_h, owned, owner, rider, home_x, home_z }` | a vehicle (change one through the verbs) |
| `vehicles_dock_at(x, z, yaw)`, `vehicles_rail_at(x, z, yaw)`, `vehicles_dock_yaw()` | where the places are measured from |
| `vehicle_berth_x/z(k)`, `vehicle_post_x/z(k)`, `vehicle_bay_x/z(k)`, `vehicle_place_x/z(kind, k)` | the places |
| `vehicle_call_for(pid, kind, k) -> bool`, `vehicle_in_place(kind, k)`, `vehicle_free_place(kind)`, `vehicle_mine_in_place(kind)` | calling one to a place |
| `vehicle_of(pid, kind)`, `vehicle_find(kind)`, `vehicle_nearest(x, z, reach)`, `vehicles_all()`, `vehicle_current()`, `vehicle_ride_kind()` | questions |
| `vehicle_mount(v) -> bool`, `vehicle_dismount() -> bool`, `vehicle_drop()` | on and off |
| `vehicle_update(ix, iz, run, dt)` | a frame of riding from the rider's stick (bind it where the body hands its stick over) |
| `vehicle_own(v)`, `vehicle_feed(v, hay)`, `vehicle_follow(v, x, y, z, yaw)`, `vehicles_release(pid)`, `vehicle_restore(kind, owned, food)` | hiring, hay, a tied horse's wandering, a player leaving, a saved word |
| `vehicles_tick(dt)` | every boat's hull read back: a rowed one pushed by the wind, one nobody rows held at its mooring (the game calls it where the world is run) |
| `vehicle_facts() -> Queue<VehicleFact>` | `{ what, nid, kind, owner, x, z, v }`: `VEHICLE_MOUNTED`, `_DISMOUNTED`, `_NO_LANDING`, `_MOVED` (v: metres), `_SWELL` (every 14 s), `_HUNGRY`, `_FED` |
| `vehicles_reset()`, `vehicles_system() -> System` | `"vehicles"`: this player's own saved by kind (hired, hay) - where they lie is not saved |

## Tests

```bash
ludic test packages/ludic.vehicles
```

A fake shore with a pier head and a trough, and Maroon Lake's numbers as the specs: a kind with no
spec refused and a spec's walk and seat obeyed, berths and bays, calling and fetching, a taken place, a
player leaving, a hungry horse, riding a horse into a trunk and to the water's edge; a real Jolt hull
rowed out, losing its stroke to the swell, turned, stopped by the shore's bed and drifted by the
wind; getting off near a shore and far from one, and the save.

## Signals

The facts and values an animation graph (or a sound bank) can listen to, by name and without glue, are declared in `signals.ludic` as `SignalSources` (`ludic.base`): vehicles.MOUNTED, vehicles.speed, vehicles.seat_pose, and more. A game writes `AnimBindings` rows naming them (`ludic.anim`). They read the fact queue without draining it.
