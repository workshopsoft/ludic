bump: minor
type: feature
**`ludic schema` carries the code map: a `"code"` section.** Beside the records, registries and
`lang`, the schema now lists what an editor's code map needs, from the compiler's own reading:
`modules` (uses, layer, friend, files), `states`, `actions`, `reducers` and every `dispatch`, `events`
(cancellable, net) with every `emit` and their `@On` listeners, `ports` (members with their `fn`
types and defaults) and `binds` (port, member, the function named, where), `handlers` (phase, hook
and what it names, `@Public`, `@Server` / `@Predicted`, `@Queries` with their filters, the scene and
layer), `models` (`@Owned`, `@Sync`), `prefabs`, `scenes` (start, shows, lasts / loads and what
follows, layers) and `fn_refs` - every `fn name` in code or in a resource file, with the slot it
fills (a registry's field and row, a port's member, a record field, an argument, ...). Every place
is `"file:line:col"`; the rest of the schema is unchanged, so `schema_version` stays 1.
