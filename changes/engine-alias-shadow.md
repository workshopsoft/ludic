bump: patch
type: fix
**A function named like an engine namespace method's target is refused where that method is
called.** `Random.range` is `rng_range`, so a package's own `rng_range(a, b, c)` silently took
every `Random.range(1, 6)` (and the checker then asked for its third argument). It is now an error
naming the function, the namespace method and the call.
