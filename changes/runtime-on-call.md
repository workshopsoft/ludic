bump: patch
type: fix
**Random.* works in any program, and the value tree comes in when `value_*` is called directly.**
The seeded random numbers lived in the ECS runtime, so a tool or a program made only of `test`
blocks got "unknown function rng_range"; they are their own runtime file now, spliced on demand
(and imported by the ECS runtime for a game). A package calling `value_get` or `json_encode`
itself, without a `Value.*` / `Json.*` anywhere, now gets the value tree too.
