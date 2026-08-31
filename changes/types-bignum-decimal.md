bump: minor
type: feat
**Exact numbers for game economies — `BigInt` + `Decimal` (#52, types phase 2).**
The thing a tycoon or idle game must never round wrong. `BigInt.*` is an
arbitrary-precision integer (sign-magnitude, base-1e9 limbs) with `from`/`parse`,
`add`/`sub`/`mul`/`pow`, integer `div`/`mod`, `cmp`/`eq`/`is_zero`, `to_int` and
`str` — for idle counters and exact huge currencies that overflow a 32/64-bit
int. `Decimal.*` is an exact base-10 fixed-point number (a `BigInt` mantissa
plus a decimal scale) with `from`/`parse`, exact `add`/`sub`/`mul`, `cmp`/`eq`,
`scale`/`rescale` and `str` — so money like `0.10 + 0.20` is exactly `0.30`, no
binary rounding. Both are exact and therefore deterministic; no `f32`/`f64`. The
engine (runtime/native/bignum.ludic) is spliced in on demand, so it costs
nothing when unused and works in plain tools as well as games.
