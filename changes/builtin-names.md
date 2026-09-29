bump: patch
type: fix
**A function named like a built-in a call always takes is refused.** `function words(st, k)` compiled,
and every call to it became the built-in `words(n)` - n zeroed ints, with a pointer for n - and LLVM
refused the IR far from the cause. A top-level function whose name a call always takes as the
compiler's own (`words`, `keep`, `print`, `save`, `load`, `key`, ...; the table is
`selfhost/check/check_builtins.ludic`, held to `emit_call` by `ludic-dev syntax --check`) is now an
error at its declaration, as `run` already was. Every other built-in (`buffer`, `floats`, `double`,
...) yields to a function the program declares, in the checker as it already did in codegen.
