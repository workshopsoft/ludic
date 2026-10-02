bump: minor
type: feat
**`ref "Table.field" "Registry"` in package.ludic: a game's own registry over a package's `@Ref`.** A package
declares `@Ref(GroundKinds) kind: int` because it needs a default; a game whose rows name its own kinds writes
`ref "GroundLayers.kind" "PlaceKinds"` once, and in that program the field refers to that registry wherever an
`@Ref` is checked - a map's rows under `ludicc --check`, a `.lres` row - and the schema export reports it
(`{"name": "Ref", "args": ["PlaceKinds"], "declared": "GroundKinds", "by": "package.ludic:8"}`), so an editor
reads the same. The table is a registry (its record's field) or a record's name; a field with no `@Ref` gets
one. In the package's `entry` program (or every program, when it names none) a table, field or registry the
program lacks is an error at the manifest's line; another program under the package - a test of one part -
skips a line whose table or registry it lacks. A field set by two lines is an error. Older toolchains ignore
the line.
