bump: minor
type: feature
**The built-in ECS grows.** Every component was a fixed array of 1024 slots, so a game past 1024
entities could not have them (and until the last release silently corrupted memory trying). The
per-entity stores are heap blocks now, doubled by `L_grow` as entities outgrow them, the new slots
zero: 100 000 entities spawn and query. `Prop.has` bounds against the live capacity and
`Pool.capacity` answers it. A snapshot (`save`/`load`, `world_save`/`world_load`) records its slot
count first and a load grows to it before reading the stores back, so a snapshot's size follows the
world's instead of a fixed 1024. A mod's registered components grow with the rest.
