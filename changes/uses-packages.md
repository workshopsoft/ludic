bump: minor
type: feature
**Packages count under `uses`, and the mechanic packages hold themselves to it.** A module that
says `uses` must name every package module it reaches (`ludic_inventory`, `ludic_ui`); a package
with no `module` line is named for its directory (`ludic_render3d`), so a mechanic reaching into
the renderer is caught. Only the engine's own runtime needs no naming. `module x uses` with nothing
after it reaches no other module. A port whose every member has a default may go unbound and
answers with its defaults. ludic.base, ludic.clock, ludic.effects, ludic.inventory, ludic.wallet,
ludic.weather and ludic.tracks say `uses ludic_base` (ludic.base: nothing), and their records of
function values are ports - `clock_bind(w)`, `inv_bind(r)`, `weather_bind(w)` and `tracks_bind(w)`
are gone; a game writes `bind ClockWorld { ... }` (and so on) instead.
