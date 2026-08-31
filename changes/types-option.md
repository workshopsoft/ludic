bump: minor
type: feat
**`option` — a maybe-a-value type (#53, types phase 3).** The companion to
`result` (#46): `some(v)` wraps a present value (any i32-width scalar), `none()`
is the empty case — a missing value with no magic `-1` sentinel — and
`is_some`/`is_none`/`unwrap_or(o, fallback)` test and read it. A heap
`%Option = { i32 present, i32 value }`, additive and gated, so a program that
does not use it compiles byte-identically. With `result`/`ok`/`err`/`try`
already shipped, the concrete option/result safety types of phase 3 are done;
general tagged-union enums (variant payloads + binding `match` + exhaustiveness)
are tracked separately in #56.
