bump: minor
type: feature
**`ludic.zones`: where a world is simulated.** A disc per player, `(x, z, r)` with `r = zones_radius(fog)`
(the fog distance plus 40 m, never under 150 m, 900 m with no fog), overlapping discs merged into
clusters with a bounding circle, and `zones_contains` / `zones_nearest` for everything that asks; fixed
arrays, nothing made per frame. The packages that simulate now ask their world port whether a place is
simulated, with a default of everywhere: `WildlifeWorld.active` (an animal outside is frozen - its
state kept, no dice drawn), `NpcWorld.active` (a walker outside is frozen, and nobody is born outside),
`VehicleWorld.active` (a moored boat outside is left where it lies) and `ThingsWorld.restocks` (a
morning restocks only inside).
