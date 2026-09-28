bump: patch
type: fix
**A `Math.*` call has a type the checker knows.** `Math.max`, `Math.sqrt` and the rest are computed
inline by the emitter, and the checker gave every one of them the unknown type, which agrees with
everything - so `dispatch Notify { a1: Math.max(5, n) }` put an int into a string field, passed L4
and failed in LLVM (`%t63 defined with type i32 but expected ptr`). The checker now gives each the
type the emitter does: a float or double first argument is that type (`sign` an int); otherwise
`min`, `max`, `abs` and `clamp` keep the first argument's type, `sign`, `floor`, `ceil`, `round`,
`posmod`, `wrap` and `ping_pong` are ints and the rest fixed. The bare `min` / `max` / `abs` /
`clamp` builtins the same. Where the arguments cannot be told, the result stays unknown.
