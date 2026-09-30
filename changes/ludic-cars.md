bump: minor
type: feat
**`ludic.cars`: wheeled vehicles as data and a simulation behind ports.** Handling as rows (`CarModels`: engine
torque curve, gears, brakes, steering by speed, any number of axles with suspension, tyres from `CarTyres`' normalised
grip curves, aero, nitrous, health, arcade-to-simulation blend and assists), tuning (`CarParts`), paint
(`CarLiveries`), classes, seats and sockets (`@Asset` / `@Node` / `@Clip`). A raycast-wheel model over the game's
physics body (`CarBody`, `CarWorld.cast`; no native change to `ludic.physics`), a planar model of the same
tyres and drivetrain, and a lane follower over `CarRoad` for traffic, switched by distance. Entering, leaving and
carjacking are a `@Machine`; damage and dents are facts; ownership (garage slots, retrieve, call, store, insurance
claims, the impound) is a second `@Machine` over `CarBank` and `CarPlaces` ports; the package plays no animation,
it asks the game's animation graph for states by name (`CarAnim`). Party play is one authority per car
(the host, or the driver) with fourteen-int snapshots, an interpolation ring and refusal of impossible claims,
all without per-frame allocation.
