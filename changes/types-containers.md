bump: minor
type: feat
**Containers — `Dict` + `Set` (#54, types phase 4).** Everyday string-keyed
lookups backed by one open-addressing hash table (FNV-1a, linear probing,
tombstone deletes, grows at load factor 0.7), spliced in on demand.
`Dict.*` maps string keys to `int` values — `new`/`set`/`get`/`get_or`/`has`/
`remove`/`size`/`clear`/`keys` — for resource counts and id/name registries.
`Set.*` is a set of string members — `new`/`add`/`has`/`remove`/`size`/`clear`/
`members` — for tags, unlocked achievements and visited tiles. O(1) average
lookup instead of a linear list scan. Values are `int` (also holds an `entity`
or any small id); the `Value.*` tree already covers richer/heterogeneous maps,
and `[T; N]` inline fixed arrays remain future work (typed buffers `words` /
`fixeds` / `pointers` and `[]T` slices cover heap-backed arrays today).
