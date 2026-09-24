bump: minor
type: feature
**Registries by declaration.** `registry Furnishings of Furnishing as HF` declares a table of
records, and each `def Furnishings chair { name: "Camp chair", cost: 60 }` - in any file - is an
entry of it, filled before any code runs. Every entry gets an index constant (`HF_CHAIR`, in
declaration order), the table a count (`HF_COUNT`), and a record with a `key` field gets it filled
in and a lookup, `furnishings_find(key)`. A def's fields are checked; a record literal naming a field
its record does not have is now an error everywhere.
