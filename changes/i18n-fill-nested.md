bump: patch
type: fix
**Text keys below a row, padding, and `tr`'s cast.** A `@Text Key` in a record nested in a registry
row (and in each item of a list of them) is filled with its derived key, `<registry>.<row>.<field>.<i>.<field>`,
as a top-level one is, and a `@Text []Key` a row leaves out takes `<...>.0`, `.1`, ... for as many as
the source `.po` has - so no `.lres` spells a key. `field: null` is no text. `trf` / `trn`'s trailing
`""` arguments are padding and not counted against the English's holes. And `string(x)` of a string or
a `Key` is no allocation to the escape analysis: it is `x` itself, so a `tr(key)` that returns it
passes `arena strict` (a template's lone hole still copies).
