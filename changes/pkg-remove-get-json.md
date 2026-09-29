bump: minor
type: feat
**`ludic remove <module>` and `ludic get --json`.** `remove` is the inverse of `add`: the `require`
leaves `package.ludic`, the lock keeps what the remaining requires still reach (read from the store's
copies of each package's manifest, no network), and each package leaving the lock loses the
`ludic_modules/` link `add` made - never the shared store entry. A module that is not required is
refused; source still importing a removed package is a warning. `ludic get --json` prints what the run
changed in the lock as one JSON object on stdout - `{"added", "removed", "changed", "unchanged"}`, an
entry as the lock records it (`name`, `version`, `hash`, `kind`, `provides`), a change as `{name, from,
to, from_hash, to_hash}` - with the resolver's own lines on stderr.
