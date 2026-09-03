bump: minor
type: feat
`v.x` and `v.y` read the components of an `IVec2` value (a local, a global, a record field, or a call result) — the readable form of `IVec2.x(v)` / `IVec2.y(v)`. The compiler's static typing now also follows function return types, namespace calls, `Prop.of(e)` and record fields, so `@Computed` fields expand in those positions too.
