bump: minor
type: feature
**`@Asset(kind, map)`: a path under each map's directory.** A field whose file lives in the map's own folder
(a grass kind's density picture, `ground/blades.png`) says so, and `ludicc --check` looks for it in every
map - a @PerMap row's in its map, a game-wide row's in all of them - refusing a map that lacks it unless the
field is `@Asset(kind, map, optional)`. The schema marks the attribute `"scope": "map"`.
