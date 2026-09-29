bump: minor
type: feature
**A bake's inputs can follow the data.** `bake_expand(inputs, map)` gives a Bakes row's inputs as they are
hashed: `{map}` put as the map's key, and each input with a `*` put as the paths it matches, sorted as whole
paths byte by byte, dot-names left out, a glob matching nothing gone. `bake_maps(first_input)` is the maps a
`{map}` row covers: each directory under assets/maps holding its first input (`bake_maps_in` under another
root). A runner hashes `bake_inputs_hash(bake_expand(row.inputs, map))`, the same path the check takes, so
the two cannot disagree on stale; a game's Python tools are its checked twin.
