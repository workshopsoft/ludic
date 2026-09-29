bump: patch
type: fix
**An attribute before `export` is kept.** `@ToClients export event E`, `@Sync export property P`,
`@Owned export model M` and the rest lost the attributes written in front of `export`: the parser read
them, then parsed the declaration afresh and forgot them - so an exported remote event was silently
local; and `export @ToClients event` was refused outright. Attributes and `export` now read in
either order into the same declaration.
