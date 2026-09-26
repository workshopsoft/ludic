bump: patch
type: fix
**A misspelled type is refused where it is written.** `function kind_of(f: CharFact)` for a
`CharacterFact` used to be accepted and fail in the code writer as "member access on non-aggregate",
far from the typo. A capitalised type in a parameter, a result or a field (plain, in a slice, or as a
generic's argument) must name a declared property, record, state, event, enum or action, or a type
parameter of its declaration: `kind_of's parameter f: there is no type CharFact`.
