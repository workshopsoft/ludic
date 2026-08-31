bump: minor
type: feat
**Polish numeric types — `Huge` + `Angle` + `Percent` (#55, types phase 5).**
`Huge.*` is an idle/incremental big number (normalized mantissa x 10^exponent)
reaching far past the integer range — `from`/`add`/`sub`/`mul`/`neg`/`cmp`/
`sign`/`mantissa`/`exp`/`str` (scientific `1.23e45`); it is display-scale, not
lockstep-exact (use BigInt/Decimal for exactness). `Angle.*` is an auto-wrapping
radian angle — `from_degrees`/`to_degrees`/`wrap`/`sin`/`cos`/`add`/`diff`
(shortest signed rotation)/`lerp` (shortest arc) — over the deterministic
`Math.*` trig. `Percent.*` is a value clamped to [0,1] — `clamp`/`of`/`lerp`/
`apply` — for health fractions, volumes and interpolation `t`. All spliced in on
demand. Remaining phase-5 items are already covered or need front-end work:
`duration` = `Duration.*`, `rune`/`char` = `Unicode.*`, `i64` = `long`; and the
nominal-safety wrappers `handle` / typed `name` plus the other sized ints need a
type-checking pass, tracked for later.
