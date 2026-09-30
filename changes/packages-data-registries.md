bump: minor
type: feat
**Weather, clock, vehicles, physics colliders, ground layers and water are data now**, not records a
game hands in through functions: each package has an open (or per-map) registry a game fills with
`def X from "file.lres"`, so an editor can author them.

- **`ludic.weather`**: `WeatherKinds` (one row a kind, `WK_<KEY>`, `@Range`/`@Unit` on its numbers) and
  `WeatherSettings` (the valley's wind). `ludic.clock`: `ClockSettings` (the day's length in real minutes, start
  hour, night, moon, calendar).
- **`ludic.vehicles`**: `VehicleSpecs` (a kind's numbers and model) and `VehicleSeats` (where a rider sits, in the
  model's space). **`ludic.physics`**: `ColliderShapes`, made into shapes with `phys_shape_of`.
- **`ludic.render3d`**: `GroundLayers` (a map's painted layers: density image, what grows, the `GroundFill`
  numbers), `GroundKinds` and `WaterBodies` (a map's planes), applied with `ground_layer_fill` and
  `water_bodies_apply`. `ludic.vehicles` and `ludic.physics` ship a `studio.lres` for the seats and colliders.
- Every older entry point keeps working and wins over the rows: `weather_kinds`, `weather_config_wind`,
  `clock_config`, `clock_config_moon`, `clock_calendar`, `clock_set_scale`, `vehicles_spec`, hand-built
  `GroundFill`s and `water_init`. A game that declares its own `GroundLayers` or `WaterBodies` registry next to
  `ludic.render3d` must drop it for the package's (the private `water_bodies_clear` is now `water_planes_clear`).
