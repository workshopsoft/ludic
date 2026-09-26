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

- **Nothing is parked for anyone.** A vehicle has an `owner` and a `rider`; `vehicle_find(kind)` is
  this player's own and nothing else may pick "the" boat. A place is taken while a boat lies in it
  or a horse is tied at it (`home_x`, `home_z`), within half a place's spacing.
- **Where a body is put down is one question with one answer.** Getting off asks the rider's
  `safe_spot` - a wade of up to 1.25 m within its search from a boat, beside the right flank from a
  horse - and a boat too far out refuses and says so (`VEHICLE_NO_LANDING`) rather than dropping the
  rider in the lake.
- **A boat is a body in the game's physics** (`VehicleHull`, phase 16; a buoyant Jolt hull in Maroon
  Lake). The package rows it - the stick forward and back is a stroke along the bow, left and right
  the oars pulled against each other - and reads back where the hull is and how fast it goes. The
  water floats it, the wind (`VehicleWorld.wind`) drifts every boat, ridden or not, and the lake bed
  stops it at the shore; the swell at the sail limit takes the outward share of a stroke.
- **A horse's steering follows signed speed**: backing up with the stick left swings the nose right.
- A stale rider locks a vehicle for ever, so getting off is `vehicle_dismount` or `vehicle_drop`.

## The ports

`VehicleHull { put(nid, x, y, z, yaw), row(nid, forward, turn), drift(nid, fx, fz), read(nid) -> bool,
x, y, z, yaw, speed, gone(nid) }` is required: the boat's body, named by the vehicle's nid.

```ludic
export port VehicleWorld {
  ground: fn(float, float) -> float                       # required
  water: fn(float, float) -> float                        # the surface (unbound: never wet)
  blocked: fn(float, float, float) -> bool                # (x, z, r): a collider in a horse's way
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
| `VEHICLE_HORSE`, `VEHICLE_BOAT`, `VEHICLE_PLACES`, `VEHICLE_HAY_MIN` | the kinds, four places each, and the hay a horse needs to go |
| `Vehicle { kind, nid, x, y, z, yaw, speed, fuel, food, seat_h, owned, owner, rider, home_x, home_z }` | a vehicle (change one through the verbs) |
| `vehicles_dock_at(x, z, yaw)`, `vehicles_rail_at(x, z, yaw)`, `vehicles_dock_yaw()` | where the places are measured from |
| `vehicle_berth_x/z(k)`, `vehicle_post_x/z(k)`, `vehicle_bay_x/z(k)`, `vehicle_place_x/z(kind, k)` | the places |
| `vehicle_call_for(pid, kind, k) -> bool`, `vehicle_in_place(kind, k)`, `vehicle_free_place(kind)`, `vehicle_mine_in_place(kind)` | calling one to a place |
| `vehicle_of(pid, kind)`, `vehicle_find(kind)`, `vehicle_nearest(x, z, reach)`, `vehicles_all()`, `vehicle_current()`, `vehicle_ride_kind()` | questions |
| `vehicle_mount(v) -> bool`, `vehicle_dismount() -> bool`, `vehicle_drop()` | on and off |
| `vehicle_update(ix, iz, run, dt)` | a frame of riding from the rider's stick (bind it where the body hands its stick over) |
| `vehicle_own(v)`, `vehicle_feed(v, hay)`, `vehicle_follow(v, x, y, z, yaw)`, `vehicles_release(pid)`, `vehicle_restore(kind, owned, food)` | hiring, hay, a tied horse's wandering, a player leaving, a saved word |
| `vehicles_tick(dt)` | every boat's hull read back and pushed by the wind (the game calls it where the world is run) |
| `vehicle_facts() -> Queue<VehicleFact>` | `{ what, nid, kind, owner, x, z, v }`: `VEHICLE_MOUNTED`, `_DISMOUNTED`, `_NO_LANDING`, `_MOVED` (v: metres), `_SWELL` (every 14 s), `_HUNGRY`, `_FED` |
| `vehicles_reset()`, `vehicles_system() -> System` | `"vehicles"`: this player's own saved by kind (hired, hay) - where they lie is not saved |

## Tests

```bash
ludic test packages/ludic.vehicles
```

A fake shore with a pier head and a trough: berths and bays, calling and fetching, a taken place, a
player leaving, a hungry horse, riding a horse into a trunk and to the water's edge; a real Jolt hull
rowed out, losing its stroke to the swell, turned, stopped by the shore's bed and drifted by the
wind; getting off near a shore and far from one, and the save.
