bump: minor
type: feature
**Entity verbs are owned by the packages.** `ludic.character` declares `player` (`x y z yaw vx vy vz grounded`),
`ludic.crowd` `peds_near` / `ped_get`, `ludic.cars` `cars_near` / `car_get`: a game that uses them offers them to the
editor link with no code. `<kind>_near x z r max?` answers a count and fixed-width records, nearest first, at most 16
(`max` defaults to 12) so the reply stays inside `DV_OUT`; `<kind>_get id` answers one record. Yaw on the wire is
render3d's, in degrees [0, 360) (`dv_reply_yaw`, 0 faces -z). `ludic.base` gains `dv_near_limit`, `DV_NEAR_DEFAULT`,
`DV_NEAR_MAX` and `dv_reply_yaw`. See `ludic.devlink/README.md`.
