bump: minor
type: feature
**`ludic.session`: `ply_rest_least()`, the party's rest for the clock** - the least any player on is
resting, 1 while one is on their feet, so one player sitting never hurries another's day. A game binds it
straight to `ClockWorld.rest_scale`. Its tests now also hold a freed slot handed to the next to join,
`ply_leave_all`, and the nearest player alone being this one at its own distance; `ludic.shop`'s own test
holds that rolling and asking the week's demand leaves the world's shared `Random` stream where it was.
