bump: minor
type: feature
**`ludic.cars`, `ludic.physics`: a parked car costs about nothing.** A game that fills its car parks with real cars (bodies near the
player, planar models further out) paid for every one of them every step, at rest or not: a car park of 90 parked sedans cost 0.47 ms a
frame (Jolt 5.6, 60 Hz), 95 % of it Jolt's step, where a wheeled vehicle casts its four wheel cylinders every step even with its body
asleep (`VehicleConstraint::mNumStepsBetweenCollisionTestInactive` defaults to 1).

* `ludic.physics`: a vehicle asleep does not cast its wheels again (`SetNumStepsBetweenCollisionTestInactive(0)` in `jph_vehicle_make`):
  Jolt's simplified test keeps the last contacts, which nothing can change while nothing wakes the body (a contact, a push, a pedal or
  the wheel all do). A contact body taken away is let go by Jolt as before. Awake, every wheel is cast every step as before.
* `ludic.cars`: `CarBody.awake(nid)`, a new port field (unbound: always awake, the old behaviour). A body car nobody is in, getting into
  or driving, with no AI and no horn, whose body the game says is asleep is not stepped (no read, no pedals, no wheels); a planar car
  or lane-following car left alone that has stood still `CAR_REST_T` (1 s, under `CAR_REST_V`) is not stepped either. `Car.asleep` says which were left the
  last step, `cars_asleep(st)` how many. A driver, a door or the AI steps the car again from the next step.

* `ludic.cars`: `car_body_near(st, nid, m)`: a car that needs a body only close up (a parked car) is a body within `m` of a viewer
  when that is under `CarSettings.body_dist`, a planar car further out (0 gives it the settings' distance again). A full car park
  within the 150 m body distance was more Jolt vehicles than `ph_vehicles`' 256. `car_place` now also clears the rest timer.

Measured (the OccuTown sedan, 60 Hz): 90 parked bodies 468 -> 57 us a frame; 90 parked planar cars 200 -> 3 us. Tests:
`vehicle_test` "asleep it casts no wheel but keeps its contacts and its height; a push wakes it", `cars_planar_test` "a car nobody is
at ... is not stepped", `cars_body_test` "a car given a nearer body distance". The macos-arm64 library is rebuilt (Jolt v5.6.0, SHA-256 checked); the windows-x64 one needs `native/build.sh`
on the PC (no new symbols: until then a parked vehicle there is cast as before).
