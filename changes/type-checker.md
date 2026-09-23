bump: minor
type: feature
**A type checker runs before the emitter.** Numbers of different kinds, text and numbers, two
record types, slices of different elements and functions of different types no longer mix; a call
with the wrong number of arguments, a `return` of the wrong type and a `push` of the wrong element
are errors with a line - several of these reached clang as an IR error, or compiled and ran wrong.
Every mix-up is reported in one run. `pointer` stays untyped. `LUDIC_CHECK_REPORT=1` lists them by
category without failing.

It found, and this release fixes: render3d's HDR sky scan calling the float-bits extern `f_lt` with
floats (it passed them in float registers the callee never read); `ludic.shooter`'s right-stick aim
scaling a fixed deflection by 65536 again, which overflowed past half a push and turned the aim
round; `prof.ludic` storing longs in an `[]int`; and extern calls, whose arguments are now coerced
to their parameters like a function's. Runtime functions that return text (`Json.encode`, the
value, XML, Tiled, HTTP and regex readers, `gl_get_string`) say `string`, and `Assets.ready()`
says `bool`.
