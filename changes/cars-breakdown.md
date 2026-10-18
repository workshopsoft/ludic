bump: minor
type: feature
**`ludic.cars`: a car can break down instead of wrecking, and a hurt engine sputters.** `CarSettings.breakdown`
(off by default) turns health at 0 into a breakdown: `CAR_BROKEN`, health held at 0, the engine dead and off (it will
not start), nobody thrown out, steering and brakes kept; `car_broken(cars_st, c)` asks. `car_set_health(nid, hp)` sets
the body's health (a broken car given health has its engine back, in proportion, and runs under a driver);
`car_repair` restarts the engine under a driver. `CarSettings.sputter_at` (0 off): under that share of body health a
running engine misfires (`CAR_MISFIRE`), the torque falling with the health; both drivetrains share the hurt engine's
share (`cr_engine_share`). Fixed: with the engine off the brake pedal of a vehicle or a planar car stayed reverse's
throttle once the car had backed up, so it did not brake.
