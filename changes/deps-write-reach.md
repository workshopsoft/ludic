bump: minor
type: feat
**`ludic deps` says what a function can come to CHANGE** (`widest_write_reach`, and `--wreach N`
lists the functions by it): the states it reaches as `mut`, through calls, `fn` values and step
lists. Reach itself is sharper: `Port.member()` reaches that member's binding only, and
`Registry[i].field` (or a local holding `Registry[i]`) reaches that field only - a question asked of
a port or a table that also holds verbs no longer reaches the verbs.
