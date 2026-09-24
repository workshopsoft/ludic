bump: minor
type: feature
**Resource files.** `registry Tools of Tool as TL from "data/tools.lres"` fills a registry from a
data file of `key { field: value }` entries. It is read at compile time with the registry's record as
its schema - a misspelt field, a wrong type or a repeated key is a compile error at the resource
file's line - and compiled in, so nothing parses at start-up. Nested records and lists of them are
bare `{ ... }` / `[{ ... }]`, typed by the schema; values are expressions, so an entry names another
table's entry by its constant.
