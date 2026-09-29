bump: minor
type: feature
**`ludic.vehicles`: a kind's numbers are the game's.** The seat height, a horse's walk, gallop,
acceleration and turn, its stamina and hay, a boat's stroke, turn and the wind on it, and where a rider
gets off (the horse's flank, the boat's wade) were constants in the package; they are a `VehicleSpec` a
game hands each kind with `vehicles_spec(kind, spec)` before any vehicle of it is called, and
`vehicle_spec(kind)` asks them. A kind with no spec cannot be called, and a reset keeps the specs.
`VEHICLE_HAY_MIN` is gone: it is the horse spec's `hay_min`.
