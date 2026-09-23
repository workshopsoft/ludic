bump: minor
type: feat
**A local is declared once per block, and a function returns what it says it returns.** A second
`let` or `var` of a name in the same block used to shadow the first silently - a settings page
compared a vegetation setting against the volumetric one because of it - and is now an error.
Names declared in different blocks, loop variables and parameters are unaffected. And a function
with a result type that can reach the end of its body without a `return` is an error: it used
to hand back whatever its result slot held, which is how a self-test split into helpers
reported FAILED for a step that had passed. `examples/rejected/` holds both.
