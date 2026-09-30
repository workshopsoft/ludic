bump: patch
type: fix
**ludic.cars planar model no longer spins out and never carries a NaN.** The body-axes turn was added to the velocity by
explicit Euler, which multiplies the speed by sqrt(1 + (w dt)^2) every step, so a hard turn at speed fed its own spin (a sedan at
30 m/s with the stick at 0.6 went to 177 m/s). The turn is now an exact rotation of the (forward, right) velocity by the yaw step,
the yaw rate and the speed are bounded, and the load transfer reads the force's acceleration, not the rotation's. `car_spawn`,
`car_place` and `car_drive` turn NaN and infinities into 0, a ground that answers with none is level with the car, and a body pose
that is not finite hands the car to the planar model. `is_finite(x)` joins ludic.base.
