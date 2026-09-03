bump: minor
type: feat
`Prop.of(entity)` and `Prop.has(entity)` — typed access to one entity's component from an entity handle, the same binding a query loop makes. `Hero.of(player).iframes = 20` reads and writes fields directly (no `World.prop_id` / `World.field_id` / `World.get` reflection chain); `Prop.has(e)` is true when `e` is in range, alive, and carries the property, so `-1` is a safe "no entity". A package that declares a real `prop_of` / `prop_has` function keeps it.
